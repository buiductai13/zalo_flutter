// ignore_for_file: file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:zalochat/components/PasswordTextField.dart';
import 'package:zalochat/components/EmailTextField.dart';
import 'package:zalochat/models/userModel.dart';
import 'package:zalochat/pages/ConfirmAccount-Page.dart';

// ignore: must_be_immutable
class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void checkValues(BuildContext context) {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = confirmPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      print("Vui lòng đừng để trống các ô!");
    } else if (password != cPassword) {
      print("Mật khẩu xác nhận không trùng khớp!");
    } else {
      signUp(email, password, context);
    }
  }

  Future<void> signUp(
      String email, String password, BuildContext context) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepicture: "",
        friendList: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("Đăng ký thành công!");

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ConfirmAccount(
            firebaseUser: credential!.user!,
            userModel: newUser,
          );
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 88, 235),
        title: const Text(
          "Tạo tài khoản",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(children: [
              const SizedBox(height: 25.0),

              //Phone number textfield

              MyEmailTextField(
                controller: emailController,
              ),
              const SizedBox(height: 20.0),

              //Password textfield

              MyPasswordTextField(
                  controller: passwordController, myText: "Mật khẩu"),
              const SizedBox(height: 20.0),

              //Confirm password
              MyPasswordTextField(
                  controller: confirmPasswordController,
                  myText: "Xác nhận mật khẩu"),
              const SizedBox(height: 20.0),
              //Dieu khoan cua app

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Những lưu ý khi đặt tên:",
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text("- Đặt tên phù hợp với"),
                      SizedBox(width: 5),
                      Text("điều khoản của Zalo",
                          style: TextStyle(color: Colors.blue))
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                      "- Sử dụng tên thật để mọi người dễ nhận ra bạn"),
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
        backgroundColor: Colors.blueAccent.shade700,
        shape: const StadiumBorder(),
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
        ),
      ),
    );
  }
}
