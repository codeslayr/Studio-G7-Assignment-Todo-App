import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:studio_g7_assignment_todo_app/models/todo_model.dart';
import 'package:studio_g7_assignment_todo_app/services/database_services.dart';

class PendingWidget extends StatefulWidget {
  const PendingWidget({super.key});

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late String uid;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    //ToDo: implemet initState
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _databaseService.todos,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Todo> todos = snapshot.data!;
          return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Todo todo = todos[index];
                final DateTime dt = todo.timestamp.toDate();
                return Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10)),
                  child: Slidable(
                      key: ValueKey(todo.id),
                      endActionPane:
                          ActionPane(motion: DrawerMotion(), children: [
                        SlidableAction(
                            backgroundColor: Colors.green,
                            icon: Icons.done,
                            label: "Done",
                            onPressed: (context) {
                              _databaseService.updateTodoStatus(todo.id, true);
                            }),
                      ]),
                      startActionPane:
                          ActionPane(motion: DrawerMotion(), children: [
                        SlidableAction(
                            backgroundColor: Colors.blueAccent,
                            icon: Icons.edit,
                            label: "Edit",
                            onPressed: (context) {
                              _showTaskDialog(context, todo: todo);
                            }),
                        SlidableAction(
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: "Delete",
                            onPressed: (context) async {
                              await _databaseService.deleteTodotask(todo.id);
                            }),
                      ]),
                      child: ListTile(
                        title: Text(
                          todo.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        subtitle: Text(
                          todo.description,
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          "${dt.day}/${dt.month}/${dt.year}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      )),
                );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }
      },
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
            backgroundColor:
                Colors.white, // Dialog background color set to black
            title: Text(
              todo == null ? "Add Task" : "Edit Task",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black, // Title text color set to white
              ),
            ),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: Colors.black), // Text color white
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white, // Background color black
                        labelText: "Title",
                        labelStyle:
                            TextStyle(color: Colors.black), // Label color white
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black), // Focus border black
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _descriptionController,
                      style: TextStyle(color: Colors.black), // Text color white
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white, // Background color black
                        labelText: "Description",
                        labelStyle:
                            TextStyle(color: Colors.black), // Label color white
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black), // Focus border black
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
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
                  style: TextStyle(color: Colors.black), // Text color white
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.black, // Button background color black
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
                  style: TextStyle(color: Colors.white), // Text color white
                ),
              ),
            ],
          );
        });
  }
}
