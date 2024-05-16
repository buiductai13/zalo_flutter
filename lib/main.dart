import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zalochat/models/firebaseHelper.dart';
import 'package:zalochat/models/userModel.dart';
import 'package:zalochat/pages/Home-Page.dart';
import 'package:zalochat/pages/Main-Page.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  var box = await Hive.openBox("mybox");
  await Firebase.initializeApp();
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    //Logged In
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel == null) {
      // User data not found in Firebase, sign out the user
      await FirebaseAuth.instance.signOut();
      runApp(const MyApp());
    } else {
      runApp(MyLoggedApp(
        firebaseUser: currentUser,
        userModel: thisUserModel,
      ));
    }
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class MyLoggedApp extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyLoggedApp(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}

// chức năng đăng bài
class History extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const History({Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
