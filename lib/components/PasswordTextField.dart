// ignore_for_file: file_names

import "package:flutter/material.dart";

class MyPasswordTextField extends StatefulWidget {
  const MyPasswordTextField(
      {Key? key, required this.controller, required this.myText})
      : super(key: key);
  final TextEditingController controller;
  final String myText;
  @override
  // ignore: library_private_types_in_public_api
  _MyPasswordTextFieldState createState() => _MyPasswordTextFieldState();
}

class _MyPasswordTextFieldState extends State<MyPasswordTextField> {
  var obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            hintText: widget.myText,
            suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                child: obscureText
                    ? const Text(
                        "HIỆN",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      )
                    : const Text(
                        "ẨN",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ))));
  }
}
