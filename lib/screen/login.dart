import 'package:firebase/controller/controller.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import './task.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatelessWidget {
  final String google = 'assets/google.svg';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: TextButton(
            child: Text(
              'Skip',
              style: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w500,
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: Center(
            child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  // color: Color.fromRGBO(11, 113, 126, 1),
                  color: Colors.deepPurpleAccent),
              height: 80,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'todo',
                  style: GoogleFonts.pacifico(fontSize: 40),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Image.asset('assets/task.png')),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  child: Container(
                    
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 8,
                        ),
                        Container(
                          height: 20,
                          child: SvgPicture.asset(google),
                        ),
                        Container(
                          child: Text(
                            'Sign in with Google',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                    height: 40,
                    width: 200,
                  ),
                  onTap: () {
                    signIn().whenComplete(() {
                      var userid = FirebaseAuth.instance.currentUser;
                      Get.to(MyHomePage(
                        uid: userid.uid,
                      ));
                    });
                  },
                ),
                SizedBox(
                  height: 17,
                )
              ],
            ),
          ],
        )),
      ),
    );
  }
}
