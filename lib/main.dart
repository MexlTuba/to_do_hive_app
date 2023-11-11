// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'todo_item.dart';
import 'todo_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TodoItemAdapter());
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final TodoService _todoService = TodoService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
            future: _todoService.getAllTodos(),
            builder:
                (BuildContext context, AsyncSnapshot<List<TodoItem>> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return TodoListPage();
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }
}

class TodoListPage extends StatelessWidget {
  final TodoService _todoService = TodoService();
  final TextEditingController _textEditingController = TextEditingController();
  TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TO DO List Using Hive",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 32.0,
            color: Color(0xFF313144),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 255, 229),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TodoItem>('todoBox').listenable(),
        builder: (context, Box<TodoItem> box, _) {
          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              var todo = box.getAt(index);
              return ListTile(
                title: Text(todo!.title),
                leading: Checkbox(
                  activeColor: Colors.teal,
                  value: todo.isCompleted,
                  onChanged: (val) {
                    _todoService.updateIsComplete(index, todo);
                  },
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _todoService.deleteTodo(index);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 255, 229),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    'Add Todo',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 24.0,
                      color: Color(0xFF313144),
                    ),
                  ),
                  content: TextField(
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan),
                      ),
                    ),
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    cursorColor: Colors.teal,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 24.0,
                      color: Color(0xFF313144),
                    ),
                    controller: _textEditingController,
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(353, 56),
                      ),
                      child: Text(
                        'Add',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 24.0,
                        ),
                      ),
                      onPressed: () async {
                        var todo = TodoItem(_textEditingController.text, false);
                        await _todoService.addItem(todo);
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
