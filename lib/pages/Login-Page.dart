// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:zalochat/components/EmailTextField.dart';
import 'package:zalochat/components/PasswordTextField.dart';
import 'package:zalochat/models/userModel.dart';
import 'package:zalochat/pages/Main-Page.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void checkValues(BuildContext context) {
    String password = passwordController.text.trim();
    String email = emailController.text.trim();

    if (password == "" || email == "") {
      print("Vui lòng đừng để trống các ô!");
    } else {
      login(email, password, context);
    }
  }

  Future login(String email, String password, BuildContext context) async {
    UserCredential? credentical;
    try {
      credentical = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.message.toString());
    }
    if (credentical != null) {
      String uid = credentical.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      // ignore: unused_local_variable
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);
      print("Đăng nhập thành công!");
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MainPage(
          firebaseUser: credentical!.user!,
          userModel: userModel,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade700,
        title: const Text(
          "Đăng nhập",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20.0,
                ),
                Text("Nhập số điện thoại và mật khẩu để đăng nhập"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(children: [
              const SizedBox(height: 35.0),
              MyEmailTextField(controller: emailController),
              const SizedBox(height: 20.0),
              MyPasswordTextField(
                  controller: passwordController, myText: "Mật khẩu"),
              const SizedBox(height: 15.0),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lấy lại mật khẩu",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          checkValues(context);
        },
        shape: const StadiumBorder(),
        backgroundColor: Colors.blueAccent.shade700,
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}
