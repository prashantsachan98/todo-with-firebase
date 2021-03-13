import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/controller/controller.dart';
import 'package:firebase/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  final String uid;
  MyHomePage({this.uid});
  @override
  _MyHomePageState createState() => _MyHomePageState(uid);
}

class _MyHomePageState extends State<MyHomePage> {
  final String uid;
  _MyHomePageState(this.uid);
  TextEditingController t = TextEditingController();
  var taskcollection = FirebaseFirestore.instance.collection('tasks');
  String task;

  TimeOfDay _selectedTime;
  String time;

  void _presentTimePicker() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedDate;
        time = _selectedTime.toString();
      });
    });
  }

  void showdialog(bool isUpdate, DocumentSnapshot ds) {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
            scrollable: false,
            title: isUpdate == false ? Text('Add Todo') : Text('Update'),
            content: Form(
              key: formkey,
              child: TextFormField(
                  controller: t,
                  autofocus: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Task'),
                  validator: (_val) {
                    if (_val.isEmpty) {
                      return "can't be empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (_val) {
                    task = _val;
                  }),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: _presentTimePicker,
                        child: Text('select Time')),
                    ElevatedButton(
                      child: Text('Add'),
                      onPressed: () {
                        if (isUpdate) {
                          taskcollection
                              .doc(uid)
                              .collection('task')
                              .doc(ds.id)
                              .update({
                            'task': task,
                            'time': DateTime.now(),
                            'taskTime': time
                          });
                        } else
                          taskcollection.doc(uid).collection('task').add({
                            'task': task,
                            'time': DateTime.now(),
                            'taskTime': time
                          });
                        Navigator.pop(context);
                        time = DateTime.now().toString();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                signOutUser().whenComplete(() => Get.offAll(Login()));
              })
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: taskcollection
                  .doc(uid)
                  .collection('task')
                  .orderBy('taskTime')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];

                        return Card(
                          child: ListTile(
                            trailing: InkWell(
                              child: Icon(Icons.delete),
                              onTap: () => taskcollection
                                  .doc(uid)
                                  .collection('task')
                                  .doc(ds.id)
                                  .delete(),
                            ),
                            title: Text(ds['task']),
                            subtitle: Text(ds['taskTime']),
                            onLongPress: () {
                              showdialog(true, ds);
                            },
                          ),
                        );
                      });
                } else if (snapshot.hasError) {
                  return CircularProgressIndicator();
                } else
                  return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showdialog(false, null);
        },
      ),
    ));
  }
}
