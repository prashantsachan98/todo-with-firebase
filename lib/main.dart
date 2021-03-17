import 'package:firebase/screen/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/controller.dart';
import 'screen/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool isLogin = await loginCheck();

  runApp(MyApp(isLogin));
}

class MyApp extends StatelessWidget {
  var isLogin;
  var test = FirebaseAuth.instance.currentUser;
  MyApp(this.isLogin);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        home: isLogin
            ? MyHomePage(
                uid: test.uid,
              )
            : Login());
  }
}
