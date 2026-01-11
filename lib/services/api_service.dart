import '../models/todo_model.dart';

class ApiService {
  //Simulates fetching data from a remote server
  Future<List<Todo>> fetchRemoteTodos()async {
    await Future.delayed(const Duration(seconds:2));
    return [
      Todo(id:'1', title: 'Todo 1', subtitle: 'Subtitle 1'),
      Todo(id:'2', title: 'Todo 2', subtitle: 'Subtitle '),
    ];
  }
}