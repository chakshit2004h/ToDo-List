import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todolist/pages/addtodo.dart';
import 'package:http/http.dart' as http;

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List items =[];
  @override
  void initState(){
    super.initState();
      fetchTodo();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
        centerTitle: true ,
        backgroundColor: Colors.black54,
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> Addtodo()));}, label: Text("Add Todo"),),
      body: RefreshIndicator(
        onRefresh: fetchTodo,
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context,index){
              final item = items[index] as Map;
              final id = item['_id'] as String;
              return ListTile(
                leading: CircleAvatar(child: Text("${index+1}"),),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value){
                    if(value == 'delete'){
                      deleteBy(id);
                    }
                  },
                    itemBuilder: (context){
                      return [
              PopupMenuItem(
              child: Text("Delete"),value: 'delete',),
                      ];
              },)
              );
            },
        ),
      )
    );
  }
  Future<void> fetchTodo()async {
    final url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if(response.statusCode == 200){
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;

      setState(() {
        items = result;
      });
    }
  }
  Future<void> deleteBy(String id) async {
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      print("Deleted successfully from server");
      final filteredItems = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItems;
      });
      successMessage("Task deleted successfully!");
    } else {
      final errorDetails = jsonDecode(response.body);
      print("Error details: $errorDetails");
      errorMessage("Deletion failed. Error: ${response.statusCode}");
    }
  }

  void successMessage(String message){
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void errorMessage(String message){
    final snackBar = SnackBar(content: Text(message,style: TextStyle(),),backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
