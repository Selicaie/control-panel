import 'package:controlpanel/chat_room.dart';
import 'package:controlpanel/class/project.dart';
import 'package:controlpanel/class/task.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'class/src.dart';


class Task_info extends StatefulWidget{
  String ?project_name;
  String ?task_name;
  String ?status;
  Task_info(this.project_name, this.task_name,this.status);
  @override
  State<StatefulWidget> createState() {
    return _Task_info(project_name,task_name,status);
  }



}

class _Task_info extends State<Task_info>{

  String ?project_name ;
  String ?task_name;
  String ?status;
  String app_mode = /*'debug_moode';*/'production_mode';
  _Task_info(this.project_name, this.task_name,this.status);

  Project ?project;
  Task ?task;
  List<Src> src =[];

  bool new_message = true;
  DatabaseReference ?ref;


  get_info(){

    ref = FirebaseDatabase.instance.reference().child(app_mode).child('projects').child(project_name!);
    // get project info
    ref!.child('info').once().then((snapshot){
      Map  map = snapshot.value;
      setState(() {
        project= Project(map['start_date']!,map['end_date']!, map['description']!);
      });
    });

    //get task info & src
    ref!.child('tasks').child(task_name!).child('info').once().then((snapshot){
      Map map = snapshot.value;
      setState(() {
        task = Task.info(map['start_date'], map['end_date'], map['description'], map['status']);
      });
      Map src_map = map['src']!;
      src_map.forEach((key, value) {
        Src temp_src = Src(key, value['link'], value['ref'], value['u_name']);
        src.add(temp_src);
      });

    });
  }
  
  @override
  void initState() {
    project = Project('', '', '');
    task = Task.info('','','','');
    get_info();

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ui of project info
              SizedBox(height: 60,),
              Padding(
                padding: const EdgeInsets.only(left: 10,bottom: 10),
                child: Text(project_name!,style: TextStyle(fontSize: 25,
                    fontWeight: FontWeight.bold,color: Colors.black),textAlign: TextAlign.start,),
              ),
              project_info(),

              // ui of task info
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 10,bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(task_name!,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black),),
                    SizedBox(width: 10,),
                    status == 'done'?Icon(Icons.alarm_on_outlined,color: Color(0xff0B8F2A),size: 20,):
                    status == 'unassigned'?Icon(Icons.adjust_outlined,color: Color(0xff013764),size: 20,):
                    Icon(Icons.watch_later_rounded,color: Color(0xffD57623),size: 20,),
                    SizedBox(width: 5,),
                    status == 'done'?Text('Done',style: TextStyle(color:Color(0xff0B8F2A) ),):
                    status == 'unassigned'?Text('Unassigned',style: TextStyle(color:Color(0xff013764) ),):
                    Text('In progress',style: TextStyle(color:Color(0xffD57623) ),),
                  ],
                ),
              ),
              task_info(),

              // ui of SRC
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 10,bottom: 10),
                child: Text('Task Process',style: TextStyle(fontSize: 25,
                    fontWeight: FontWeight.bold,color: Colors.black),textAlign: TextAlign.start,),
              ),
              Container(height:200,child: src_info()),
              SizedBox(height: 30,),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child:Icon(Icons.message_outlined,size: 30,color: Color(0xff0069BB),),backgroundColor: Colors.white,
          onPressed: (){
            //show_message_dialog();
            Navigator.push(context, MaterialPageRoute(builder:(context)=>Chat_room(project_name, task_name)));
          }),
    );
  }


  // show project information project name, description , start & end date for project
  Widget project_info(){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //shadowColor: Color(0xff11B3EB87),
      elevation: 6,
      color: Color(0xff005194),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(project!.description,style: TextStyle(fontSize: 20,color: Colors.white),textAlign: TextAlign.center),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [ 
                Text('SD: '+project!.start_date,style: TextStyle(fontSize: 18,color: Color(0xff0BB533),fontWeight: FontWeight.bold),),
                SizedBox(width: 30,),
                Expanded(child: Text('ED: '+project!.end_date,style: TextStyle(fontSize: 18,color: Color(0xffD57623),fontWeight: FontWeight.bold),)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // show task information task name, description , start & end date for task
  Widget task_info(){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //shadowColor: Color(0xff11B3EB87),
      elevation: 4,
      color: Color(0xff005194),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(task!.description,style: TextStyle(fontSize: 20,color: Colors.white),textAlign: TextAlign.center,),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('SD: '+task!.start_date,style: TextStyle(fontSize: 18,color: Color(0xff0BB533),fontWeight: FontWeight.bold)),
                SizedBox(width: 30,),
                Expanded(child: Text('ED: '+task!.end_date,style: TextStyle(fontSize: 18,color: Color(0xffD57623),fontWeight: FontWeight.bold),)),
              ],
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  // show sources information user name , link , ref links
  Widget src_info(){
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: src.length,
        itemBuilder: (context,index){
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color:Color(0xff005194)) ),
              //shadowColor: Color(0xff11B3EB87),
              elevation: 4,
              color: Colors.white,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      decoration:BoxDecoration(
                          //border: Border.all(color: Color(0xff005194),width:3 ),
                          color:Color(0xff005194) ,
                          borderRadius: BorderRadius.circular(20)),
                      width: 300,
                      padding: EdgeInsets.only(bottom: 10,top: 10),
                      child: Column(
                        children: [
                          Text(src[index].u_name,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                          Text(src[index].time,style: TextStyle(fontSize: 13,color: Colors.white),),
                        ],
                      )),
                  SizedBox(height: 20,),
                  GestureDetector(
                    child: Text('Task Link',style: TextStyle(fontSize: 23,color: Colors.blue, decoration: TextDecoration.underline),),
                    onTap: (){
                      launch(src[index].link,);
                    },
                  ),
                  SizedBox(height: 20,),
                  GestureDetector(
                    child: Text('Ref',style: TextStyle(fontSize: 23,color: Color(0xff005194),fontWeight: FontWeight.bold),),
                    onTap: (){
                      show_ref(index);
                    },
                  ),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          );
        });
  }

  show_ref(int index){
    List<String> ref = src[index].ref.split(',');
    showDialog(
        context: context,
        builder: (_){
          return AlertDialog(
            title: Container(
                decoration:BoxDecoration(
                  //border: Border.all(color: Color(0xff005194),width:3 ),
                    color:Color(0xff005194) ,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('Ref Menu',style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
            content: SizedBox(
              width: 200,
              height: 200,
              child: ListView.builder(
                  itemCount: ref.length,
                  itemBuilder: (context,i){
                    return GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(i.toString()+' _ Ref ',style: TextStyle(fontSize: 23,color: Colors.blue),),
                      ),
                      onTap: (){
                      launch(ref[i],);
                    },
                    );
                  }),
            ),
          );
        });
  }

}