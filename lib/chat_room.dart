import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'class/chat.dart';



class Chat_room extends StatefulWidget{
  String ?project_name;
  String ?task_name;
  Chat_room(this.project_name, this.task_name);

  @override
  State<StatefulWidget> createState() {
    return _Chat_room(project_name,task_name);
  }

}

class _Chat_room extends State<Chat_room>{

  String ?project_name ;
  String ?task_name;
  String app_mode = /*'debug_moode';*/'production_mode';
  _Chat_room(this.project_name, this.task_name);
  String my_name = '';
  bool wait = true;
  bool scroll = false;
  List<Chat> chat =[];
  List<String> all_users = [];
  StreamSubscription <Event> ?added;
  TextEditingController message = TextEditingController();
  DatabaseReference ?ref;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController _scrollController = ScrollController();

  get_chat(){
      ref = FirebaseDatabase.instance.reference().child(app_mode).child('projects').child(project_name!).
      child('tasks').child(task_name!).child('chat');

      added = ref!.limitToLast(20).onChildAdded.listen((event) {
        //print(event.snapshot.value);
        Chat temp_chat = Chat(event.snapshot.key.toString(),event.snapshot.value['content'], event.snapshot.value['name']);

        setState(() {
          wait = false;
          chat.insert(0,temp_chat);
        });

      });
  }

  get_personal_info(){
    FirebaseDatabase.instance.reference().child(app_mode).child('users')
        .child(FirebaseAuth.instance.currentUser!.uid.toString()).child('info').once().then((value){
      my_name = value.value['name'];
    }).whenComplete((){ get_chat();
      setState(() {
          wait = false;
      });
    });
  }

  get_all_users(){
    FirebaseDatabase.instance.reference().child(app_mode).child('projects').child(project_name!).
    child('tasks').child(task_name!).child('users').once().then((value){
      Map map = value.value;
      map.forEach((key, value) {
        if(key != FirebaseAuth.instance.currentUser!.uid.toString())
          all_users.add(key);
      });
    });
  }

  @override
  void initState() {
    get_personal_info();
    get_all_users();
    // add listener to get listview position
    _scrollController.addListener(() {
       if( _scrollController.position.userScrollDirection==ScrollDirection.reverse) {
         if (_scrollController.offset >= 100) {
           setState(() {
             scroll = true;
           });
         }else{
           setState(() {
             scroll = false;
           });
         }
       }else
       if (_scrollController.offset <= 100) {
         setState(() {
           scroll = false;
         });
       }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 20,),

          //-------------------------list view and slide refresh----------------------------------------------------------
          Expanded(
              child:SmartRefresher(
                controller: _refreshController,
                onRefresh: (){
                  setState(() {
                    scroll = false;
                  });
                  _refreshController.refreshCompleted();
                  },
                onLoading: (){
                  ref = FirebaseDatabase.instance.reference().child(app_mode).child('projects').child(project_name!).
                  child('tasks').child(task_name!).child('chat');
                  ref!.orderByKey().endAt(chat[chat.length-1].time).limitToLast(15).once().then((snapshot){
                    //print(snapshot.value);
                    int temp = chat.length-1;
                    Map map = snapshot.value;
                    map.forEach((key, value) {
                      Chat temp_chat = Chat(key,value['content'], value['name']);

                      setState(() {
                        chat.insert(temp,temp_chat);
                      });
                    });
                    //print(chat[chat.length-1].time);
                  }).whenComplete((){
                    setState(() {
                      chat.removeLast();
                      scroll = true;
                    });
                    _refreshController.loadComplete();});

                  },
                enablePullUp: true,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                child: ListView.builder(
                    itemCount: chat.length,
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    reverse: true,
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemBuilder: (context,index){
                      return draw_chat_message(index);
                    }),
              ),
          ),

          //------------------------------move scroll down ---------------------------------------------------
          scroll? FloatingActionButton(
              child:Icon(Icons.arrow_downward,size: 30,color: Color(0xff0069BB),),backgroundColor: Colors.white,
              onPressed: (){
                _scrollController.animateTo(0, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
              }):Container(),

          //-------------------------------------------------------
          wait?CircularProgressIndicator():Container(),

          //--------------------------text field-------------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Type Your Message',
                  border:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                suffixIcon: GestureDetector(
                    child: Icon(Icons.send,size: 30,color: Color(0xff0069BB),),
                    onTap: (){
                       send_message();
                    },
                ),
              ),
              controller: message,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
          SizedBox(height: 10,)
        ],
      ),
      //---------------------poke flat button----------------------------------------------
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.campaign_sharp,size: 30,color: Color(0xff0069BB),),
        backgroundColor: Colors.white,
        onPressed: (){
          send_notification();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  Widget draw_chat_message(int index){
    return Container(
      padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
      child: Align(
        alignment: (chat[index].name == my_name?Alignment.topLeft:Alignment.topRight),
        child: chat[index].name == my_name?
        // reciever text box
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(17),
              bottomLeft:  Radius.circular(5),
              bottomRight:  Radius.circular(5),
            ),
            color: (Colors.grey.shade200),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(chat[index].content, style: TextStyle(fontSize: 15),),
              SizedBox(height: 10,),
              Text(chat[index].time, style: TextStyle(fontSize: 10,color: Color(0xff005194)),),
            ],
          ),
        )
        // sender text box
            :Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(17),
              bottomLeft:  Radius.circular(5),
              bottomRight:  Radius.circular(5),
            ),
            color: (Colors.blue[200]),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chat[index].name, style: TextStyle(fontSize: 10,color: Color(0xff005194)),),
              SizedBox(height: 5,),
              Text(chat[index].content, style: TextStyle(fontSize: 15),),
              SizedBox(height: 10,),
              Text(chat[index].time, style: TextStyle(fontSize: 10,color: Color(0xff005194))),
            ],
          ),
        ),
      ),
    );
  }

  send_message(){
    if(my_name.isNotEmpty) {
      if (message.text.isNotEmpty) {
        message.text =  message.text.toString().trim();
        if(message.text != '') {
          setState(() {
            wait = true;
          });
          ref!.child(DateFormat('yyyy-MM-dd,HH:mm:ss').format(DateTime.now())).set(
              {
                'content': message.text,
                'name': my_name,
              }).whenComplete(() {
            _scrollController.animateTo(0, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
                setState(() {
                  scroll=false;
                  wait = false;
                  message.text = '';
                });
              }).timeout(Duration(seconds: 8), onTimeout: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Check your internet connection...',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                duration: Duration(seconds: 4),
              ));
            });
        }else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
          Text('Empty Message Not Valid...', style: TextStyle(fontSize: 20),)));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
        Text('Type Message...', style: TextStyle(fontSize: 20),)));
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
      Text('Check your internet connection...', style: TextStyle(fontSize: 20),)));
    }
  }

  send_notification(){
    for(int i=0 ; i<all_users.length;i++){
      FirebaseDatabase.instance.reference().child(app_mode).child('users')
          .child(all_users[i]).child('notifications').child('chat').set({project_name:task_name});
    }
  }

  @override
  void dispose() {
    added!.cancel();
    super.dispose();
  }
}