import 'package:flutter/material.dart';
import 'package:studio_g7_assignment_todo_app/login_screen.dart';
import 'package:studio_g7_assignment_todo_app/models/todo_model.dart';
import 'package:studio_g7_assignment_todo_app/services/auth_service.dart';
import 'package:studio_g7_assignment_todo_app/services/database_services.dart';
import 'package:studio_g7_assignment_todo_app/widget/completed_widget.dart';
import 'package:studio_g7_assignment_todo_app/widget/pending_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _buttonIndex = 0;
  final _widgets = [
    //pending task widget
    PendingWidget(),
    //Completed task widget
    CompletedWidget(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          "ToDo",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              icon: Icon(
                Icons.exit_to_app,
              )),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _buttonIndex = 0;
                  });
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 2.2,
                  decoration: BoxDecoration(
                    color: _buttonIndex == 0 ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.black), // Black border added
                  ),
                  child: Center(
                    child: Text(
                      "Pending",
                      style: TextStyle(
                          fontSize: _buttonIndex == 0 ? 16 : 14,
                          fontWeight: FontWeight.w500,
                          color:
                              _buttonIndex == 0 ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _buttonIndex = 1;
                  });
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width / 2.2,
                  decoration: BoxDecoration(
                    color: _buttonIndex == 1 ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.black), // Black border added
                  ),
                  child: Center(
                    child: Text(
                      "Completed",
                      style: TextStyle(
                          fontSize: _buttonIndex == 1 ? 16 : 14,
                          fontWeight: FontWeight.w500,
                          color:
                              _buttonIndex == 1 ? Colors.white : Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          _widgets[_buttonIndex],
        ],
      )),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            _showTaskDialog(context);
          }),
    );
  }

  void _showTaskDialog(BuildContext context, {Todo? todo}) {
    final TextEditingController _titleController =
        TextEditingController(text: todo?.title);
    final TextEditingController _descriptionController =
        TextEditingController(text: todo?.description);
    final DatabaseService _databaseService = DatabaseService();

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              todo == null ? "Add Task" : "Edit Task",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black), // Focus color set to black
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black), // Focus color set to black
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.black, // Button background color set to black
                ),
                onPressed: () async {
                  if (todo == null) {
                    await _databaseService.addTodoTask(
                        _titleController.text, _descriptionController.text);
                  } else {
                    await _databaseService.updateTodo(todo.id,
                        _titleController.text, _descriptionController.text);
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  todo == null ? "Add" : "Update",
                  style: TextStyle(
                      color: Colors.white), // Button text color set to white
                ),
              ),
            ],
          );
        });
  }
}
