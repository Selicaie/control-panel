import 'package:controlpanel/class/task.dart';
import 'package:controlpanel/sign_in.dart';
import 'package:controlpanel/task_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }


}

class _Home extends State<Home>{

  String? uid;
  String? project_name ;
  String app_mode = /*'debug_moode';*/'production_mode';
  List <String> project_list = [];
  List <Task> task_list =[];
  Map<dynamic,List<Task>> proj_tasks = {};
  DatabaseReference ?ref ;

  get_projects(){
    uid = FirebaseAuth.instance.currentUser!.uid.toString();
    ref = FirebaseDatabase.instance.reference().child(app_mode).child('users').child(uid!);
    ref!.child('projects').once().then((snapshot){

      Map map = snapshot.value;
      map.forEach((key, value) {
        setState(() {
          project_list.add(key);
        });
        Map temp_map=value;
        List<Task> temp_list =[];
        temp_map.forEach((key, value) {
          Task task = Task(key,value);
          temp_list.add(task);
        });
        proj_tasks[key]=temp_list;
      });
    }).timeout(Duration(seconds: 30),onTimeout: (){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Check your internet connection...',
            style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
        duration: Duration(seconds: 4),
      ));
    });
  }

// listener for new notification
  fire_listener(){
    ref!.child('notifications').onChildAdded.listen((event) {
      Map map = event.snapshot.value;
      map.forEach((key, value) {

        if(event.snapshot.key=='chat') {
          scheduleAlarm(' you have been pocked from "$value" in "$key" ', 'New Message');
          ref!.child('notifications').child('chat').child(key).remove();
        }else {
          scheduleAlarm(' you have been added to a new task "$value" at project "$key" ', 'New Task');
          ref!.child('notifications').child('task').child(key).remove();
        }

      });
    });

  }

  @override
  void initState() {
    get_projects();
    fire_listener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Padding(
         padding: const EdgeInsets.all(10),
         child: Column(
           children: [

             // ui for sign out
             SizedBox(height: 40,),
              UI_sign_out(),

             project_list.isEmpty?CircularProgressIndicator():Container(),

             // ui  for project drop down button
             SizedBox(height: 40,),
             UI_project(),

//*********************************************************************************************************
             // ui for task list
             SizedBox(height: 20,),
             task_list.isNotEmpty?Padding(
               padding: const EdgeInsets.all(10),
               child: Container(
                 decoration:BoxDecoration(
                     border: Border.all(color: Color(0xff005194),width:3 ),
                     //color:Color(0xff005194) ,
                     borderRadius: BorderRadius.circular(20),
                 ),
                 child:Padding(
                   padding: EdgeInsets.only(left: 50,right: 50,top: 10,bottom: 10),
                   child: Text('Tasks',style: TextStyle(color: Color(0xff005194),fontSize: 20,
                       fontWeight: FontWeight.bold)),
                 )
               ),
             ):Container(),
             Expanded(
                 child:ListView.builder(
                     itemCount: task_list.length,
                     itemBuilder: (context,index){
                       return GestureDetector(
                         child: Draw_row(task_list[index].task_name, task_list[index].status),
                         onTap: (){
                           Navigator.push(context,MaterialPageRoute(
                               builder: (context)=>Task_info(project_name,task_list[index].task_name,task_list[index].status )));
                         },
                       );

                     }
                 ) ),
//*********************************************************************************************************************

             // ui for status info
             SizedBox(height: 40,),
             UI_status(),
             SizedBox(height: 50,),

             Container(
               color: Color(0xff005194),
               width: 1000,
               child: Padding(
                 padding: const EdgeInsets.only(top: 10,bottom: 10),
                 child: GestureDetector(
                   child: Text('made by ahmed sobhy',style: TextStyle(fontSize: 18,color: Colors.white),textAlign: TextAlign.center,),
                   onTap: (){
                     launch('https://www.linkedin.com/in/ahmedmartin');
                   },
                 ),
               ),
             )
           ],
         ),
       ),
    );
  }


  Widget UI_project(){

    return Container(
      decoration:BoxDecoration(
          border: Border.all(color: Color(0xff005194),width:3 ),
          //color:Color(0xff005194) ,
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding:  const EdgeInsets.only(left: 40,right: 40),
        child: DropdownButton(items: project_list.map((val){return DropdownMenuItem(
          child: Text(val),value: val,);}).toList(),
          hint: Text('Select Project',style: TextStyle(color:Color(0xff005194),fontSize: 20,
              fontWeight: FontWeight.bold),textAlign: TextAlign.center,) ,
          value: project_name,
          //dropdownColor: Color(0xffD1E9FE),
          icon: Icon(Icons.arrow_drop_down_circle,color:Color(0xff005194),),
          style: TextStyle(color:Color(0xff005194),fontSize: 20,
              fontWeight: FontWeight.bold),
          onChanged: (String? value){
            setState(() {
              project_name = value!;
              task_list.clear();
              task_list.addAll(proj_tasks[project_name]!);
            });
          },
        ),
      ),
    );

  }

  Widget UI_status(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Text('Done',style: TextStyle(color:Color(0xff0B8F2A) ),),
            Icon(Icons.alarm_on_outlined,color: Color(0xff0B8F2A),size: 20,)
          ],
        ),
        Row(
          children: [
            Text('In progress',style: TextStyle(color:Color(0xffD57623) ),),
            Icon(Icons.watch_later_rounded,color: Color(0xffD57623),size: 20,)
          ],
        ),
        Row(
          children: [
            Text('unassigned',style: TextStyle(color:Color(0xff013764) ),),
            Icon(Icons.adjust_outlined,color: Color(0xff013764),size: 20,)
          ],
        ),
      ],
    );

  }

 Widget UI_sign_out(){

    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        child: Container(
          decoration:BoxDecoration(
            //border: Border.all(color: Color(0xff005194),width:3 ),
              color:Colors.black12 ,
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Sign out',style: TextStyle(color:Colors.black54),textAlign: TextAlign.end,),
          ),
        ),
        onTap: (){
          FirebaseAuth.instance.signOut().whenComplete((){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>Sign_in()), (route) => false);
          });
        },
      ),
    );

  }


  Widget Draw_row(String name,String status){
    return Padding(
      padding: const EdgeInsets.only(right: 50,left: 50,top: 2,bottom: 2),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color:Color(0xffD1E9FE),//Colors.blueGrey[100] ,  //rgba(0, 105, 187, 0.14)
        child: Column(
          children: [
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width:10),
                    Text(name),
                  ],
                ),
                Row(
                  children: [
                    status == 'done'?Icon(Icons.alarm_on_outlined,color: Color(0xff0B8F2A),size: 20,):
                    status == 'unassigned'?Icon(Icons.adjust_outlined,color: Color(0xff013764),size: 20,):
                    Icon(Icons.watch_later_rounded,color: Color(0xffD57623),size: 20,),
                    //Text(status,style: TextStyle(color: status == 'done'?
                    //Colors.green:status == 'wait'?Colors.red:Colors.orange),),
                    SizedBox(width: 10,)
                  ],
                )
              ],
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  int temp = 0 ;
  void scheduleAlarm(String content,String sender) async {

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'CHATbj',
      'Chatsnn',
      'Channel for Alarm notification',
      icon: 'app_logo',
      playSound: true,
      //sound:RawResourceAndroidNotificationSound('notification'),
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      largeIcon: DrawableResourceAndroidBitmap('icon'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      // sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics,iOS: iOSPlatformChannelSpecifics);
    temp++;
    await flutterLocalNotificationsPlugin.show(temp, sender, content, platformChannelSpecifics, payload: 'here');

  }

}