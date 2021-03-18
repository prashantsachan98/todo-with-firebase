import 'package:firebase_auth/firebase_auth.dart';
//import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth auth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();

Future<bool> signIn() async {
  GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

  if (googleSignInAccount != null) {
    GoogleSignInAuthentication authentication =
        await googleSignInAccount.authentication;

    final GoogleAuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);

    UserCredential result = await auth.signInWithCredential(authCredential);
    User user = result.user;

    print(user.uid);

    return Future.value(true);
  } else
    return Future.value(false);
}

signOutUser() {
  FirebaseAuth.instance.signOut();
  googleSignIn.disconnect();
}

signInAnon() async {
  UserCredential result = await auth.signInAnonymously();
  User user = result.user;
  print(user.uid);
}

Future<bool> loginCheck() async {
  var test = FirebaseAuth.instance.currentUser;
  if (test == null) {
    return await Future.value(false);
  }
  return await Future.value(true);
}
