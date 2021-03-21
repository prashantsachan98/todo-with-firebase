import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/controller/controller.dart';
import 'package:firebase/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class MyHomePage extends StatefulWidget {
  final String uid;
  MyHomePage({this.uid});
  @override
  _MyHomePageState createState() => _MyHomePageState(uid);
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate;
  final String uid;
  _MyHomePageState(this.uid);
  TextEditingController t = TextEditingController();
  var taskcollection = FirebaseFirestore.instance.collection('tasks');
  String task;
  // TimeOfDay _selectedTime;
  //String time;
  final DateTime now = DateTime.now();
  final DateFormat formatterDay = DateFormat(DateFormat.DAY);
  final DateFormat formattermonth = DateFormat(DateFormat.MONTH);
  final DateFormat formatteryear = DateFormat(DateFormat.YEAR);
  final DateFormat formatterWeekDay = DateFormat(DateFormat.WEEKDAY);

  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2022),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
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
            backgroundColor: Colors.purple[50],
            actionsPadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 0),
            scrollable: false,
            title: isUpdate == false
                ? Text(
                    'Add Todo',
                    // style: TextStyle(color: Colors.deepPurpleAccent[50]),
                  )
                : Text('Update'),
            content: Form(
              key: formkey,
              child: TextFormField(
                  controller: t,
                  autofocus: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Task',
                  ),
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
              Container(
                // padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          // backgroundColor:
                          //   MaterialStateProperty.all(Colors.white),
                          ),
                      onPressed: _presentDatePicker,
                      child: Text(
                        'select Date',
                        style: TextStyle(color: Colors.deepPurple[300]),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.deepPurpleAccent)),
                child: Text('Add'),
                onPressed: () {
                  if (_selectedDate == null) {
                    _selectedDate = DateTime.now();
                  }
                  if (task == null) {
                    return;
                  } else {
                    if (isUpdate) {
                      taskcollection
                          .doc(uid)
                          .collection('task')
                          .doc(ds.id)
                          .update({
                        'task': task,
                        'taskDate': formatterDay.format(now),
                        'time': DateTime.now()
                      });
                    } else
                      taskcollection.doc(uid).collection('task').add({
                        'task': task,
                        'taskDate': formatterDay.format(_selectedDate),
                        'taskDone': false,
                        'time': DateTime.now()
                      });
                  }
                  Navigator.pop(context);
                  _selectedDate = DateTime.now();
                  t.clear();
                },
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
      //backgroundColor: Colors.red[300],
      /*  appBar: AppBar(
        title: Text('Todo'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                signOutUser();
                Get.offAll(Login());
              })
        ],
      ),*/
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      formatterDay.format(now),
                      style: GoogleFonts.ubuntu(
                          letterSpacing: -2,
                          fontSize: 50,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(1, 1, 1, 0.6)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Text(
                          formattermonth
                              .format(now)
                              .substring(0, 3)
                              .toUpperCase(),
                          style: GoogleFonts.ubuntu(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(1, 1, 1, 0.4)),
                        ),
                        Text(
                          formatteryear.format(now),
                          style: GoogleFonts.ubuntu(
                              letterSpacing: -1,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(1, 1, 1, 0.3)),
                        )
                      ],
                    )
                  ],
                ),
                Text(
                  formatterWeekDay.format(now).toUpperCase(),
                  style: GoogleFonts.ubuntu(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(1, 1, 1, 0.4)),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: taskcollection
                  .doc(uid)
                  .collection('task')
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];
                        if (int.parse(ds['taskDate']) <
                            int.parse(formatterDay.format(DateTime.now()))) {
                          taskcollection
                              .doc(uid)
                              .collection('task')
                              .doc(ds.id)
                              .delete();
                        }
                        if (formatterDay.format(DateTime.now()) ==
                            ds['taskDate']) {
                          return Dismissible(
                            background: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: Colors.black26,
                              ),
                            ),
                            direction: DismissDirection.startToEnd,
                            resizeDuration: Duration(milliseconds: 200),
                            key: Key(snapshot.data.docs[index].id),
                            onDismissed: (direction) {
                              taskcollection
                                  .doc(uid)
                                  .collection('task')
                                  .doc(ds.id)
                                  .delete();
                            },
                            child: Card(
                              elevation: 0,
                              child: ListTile(
                                trailing: InkWell(
                                  splashColor: Colors.white,
                                  onTap: () {
                                    setState(() {
                                      ds['taskDone']
                                          ? taskcollection
                                              .doc(uid)
                                              .collection('task')
                                              .doc(ds.id)
                                              .update({'taskDone': false})
                                          : taskcollection
                                              .doc(uid)
                                              .collection('task')
                                              .doc(ds.id)
                                              .update({'taskDone': true});
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ds['taskDone']
                                            ? Colors.green[400]
                                            : Colors.grey),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ds['taskDone']
                                          ? Icon(
                                              Icons.check,
                                              size: 20.0,
                                              color: Colors.white,
                                            )
                                          : Icon(
                                              Icons.circle,
                                              size: 20.0,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ),
                                ),

                                /* leading: InkWell(
                                child: Icon(Icons.delete),
                                onTap: () => taskcollection
                                    .doc(uid)
                                    .collection('task')
                                    .doc(ds.id)
                                    .delete(),
                              ),*/
                                title: Text(ds['task'],
                                    style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: ds['taskDone']
                                            ? Colors.black26
                                            : Colors.black54)),
                                //subtitle: Text(ds['taskTime']),
                                onLongPress: () {
                                  showdialog(true, ds);
                                },
                                onTap: () {
                                  signOutUser();
                                  Get.off(Login());
                                },
                              ),
                            ),
                          );
                        } else
                          return SizedBox(
                            height: 0,
                          );
                      });
                } else if (snapshot.hasError) {
                  return CircularProgressIndicator();
                } else
                  return SizedBox(
                    height: 0,
                  );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () {
          showdialog(false, null);
        },
      ),
    ));
  }
}
