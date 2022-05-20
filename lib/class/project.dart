import 'package:controlpanel/class/task.dart';

class Project {
  String start_date='';
  String end_date='';
  String description='';
  List<Task> task = [];

  Project(this.start_date, this.end_date, this.description);
}