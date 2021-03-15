import 'package:firebase/controller/controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:get/get.dart';
import './screen/task.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      home: Login(),
    );
  }
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton(Buttons.Google, onPressed: () {
              
              signIn().whenComplete(() {
             
                var userid = FirebaseAuth.instance.currentUser;
                Get.to(MyHomePage(
                  uid: userid.uid,
                ));
               
              }
                
              );
            }),
            TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white)),
                child: Text(
                  'skip',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                      fontSize: 20),
                ),
                onPressed: () {
                  signInAnon().whenComplete(() {
                    var userid = FirebaseAuth.instance.currentUser;
                    Get.to(MyHomePage(
                      uid: userid.uid,
                    ));
                  });
                }),
          ],
        )),
      ),
    );
  }
}
