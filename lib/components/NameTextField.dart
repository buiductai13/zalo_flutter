// ignore_for_file: file_names

import "package:flutter/material.dart";

class MyNameTextField extends StatefulWidget {
  final TextEditingController controller;
  final String name;
  const MyNameTextField(
      {Key? key, required this.controller, required this.name})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyNameTextFieldState createState() => _MyNameTextFieldState();
}

class _MyNameTextFieldState extends State<MyNameTextField> {
  var obscureText = true;

  // ignore: recursive_getters
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: widget.name,
        ));
  }
}
