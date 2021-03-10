import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController t = TextEditingController();
  final db = FirebaseFirestore.instance;
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
                          db
                              .collection('tasks')
                              .doc(ds.id)
                              .update({'task': task, 'date': time});
                        } else
                          db.collection('tasks').add({
                            'task': task,
                            'time': DateTime.now(),
                            'date': time
                          });
                        Navigator.pop(context);
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
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.collection('tasks').orderBy('date').snapshots(),
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
                              onTap: () =>
                                  db.collection('tasks').doc(ds.id).delete(),
                            ),
                            title: Text(ds['task']),
                            subtitle: Text(ds['date']),
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
