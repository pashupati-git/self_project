//Run: flutter pub run build_runner build
import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId:0)
class Todo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isCompleted= false,
  });


  //Business Logic:Return a new instance for STATE immutability
  Todo copyWith({String? title, String? subtitle,bool? isCompleted}){
    return Todo(
      id:id,
      title: title??this.title,
      subtitle:subtitle ?? this.subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
    );
}

}



