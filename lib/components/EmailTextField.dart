// ignore_for_file: file_names

import "package:flutter/material.dart";

class MyEmailTextField extends StatefulWidget {
  final TextEditingController controller;

  const MyEmailTextField({Key? key, required this.controller})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyEmailTextFieldState createState() => _MyEmailTextFieldState();
}

class _MyEmailTextFieldState extends State<MyEmailTextField> {
  // ignore: recursive_getters
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller,
        decoration: const InputDecoration(
          hintText: "Email",
        ));
  }
}
