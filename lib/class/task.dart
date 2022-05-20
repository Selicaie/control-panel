
import 'package:controlpanel/class/chat.dart';
import 'package:controlpanel/class/src.dart';

class Task{

  String start_date='';
  String end_date='';
  String task_name='';
  String description='';
  String status='';
  List<Src>src = [];
  //List<Chat>chat = [];

  Task(this.task_name, this.status);

  Task.info(this.start_date, this.end_date, this.description, this.status);
}