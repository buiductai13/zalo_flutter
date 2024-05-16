// ignore_for_file: file_names

import 'dart:ui';
import 'package:zalochat/pages/Login-Page.dart';
import 'package:zalochat/pages/Register-Page.dart';
import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class HomePage extends StatelessWidget {
  //method giup nguoi dung dang nhap
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(alignment: Alignment.center, children: [
        SizedBox.expand(
            child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: 7,
            sigmaY: 7,
          ),
          child: Image.network(
              'https://media.istockphoto.com/id/838406396/vector/chat-bot-and-bubble-seamless-pattern.jpg?s=612x612&w=0&k=20&c=_qJrmFqCqBCHgZHvNFhkwi8dZgIgNcpRbroeCAjTKtk=',
              fit: BoxFit.cover),
        )),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //logo
                  const SizedBox(height: 10),
                  Image.asset(
                    'lib/images/zalo-logo.png',
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  //LOGIN, REGISTER BUTTONS
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      children: [
                        //LOGIN BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade700,
                            shape: const StadiumBorder(),
                            minimumSize: const Size.fromHeight(60),
                          ),
                          child: const Text("ĐĂNG NHẬP",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return LoginPage();
                            }));
                          },
                        ),

                        const SizedBox(height: 20),
                        //REGISTER BUTTON
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            shape: const StadiumBorder(),
                            minimumSize: const Size.fromHeight(60),
                          ),
                          child: const Text("ĐĂNG KÝ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return RegisterPage();
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
