import '../models/todo_model.dart';
import '../services/api_service.dart';
import '../services/hive_services.dart';

class TodoRepository{
  final ApiService _api;
  final HiveService _hive;

  TodoRepository(this._api, this._hive);

  //business logic:Synchronization Strategy
  //If Hive is empty, fetch from API and cache locally
  //this ensures the app works offline after the first sync
   Future<List<Todo>> getTodos() async {
     final box=_hive.getTodoBox();
     if(box.isEmpty){
       final remoteTodos=await _api.fetchRemoteTodos();
       for(var todo in remoteTodos){
         await box.put(todo.id,todo);
       }
     }
   return box.values.toList();
   }
   //crud business logic:Direct Hive operations
   Future<void> saveTodo(Todo todo)async=> await _hive.getTodoBox().put(todo.id, todo);
   Future<void> deleteTodo(String id)async=> await _hive.getTodoBox().delete(id);
}
