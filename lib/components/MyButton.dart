// ignore_for_file: file_names

import "package:flutter/material.dart";

class MyButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Function route;
  // ignore: use_key_in_widget_constructors
  const MyButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15),
        ),
        child: Text(text,
            style: TextStyle(
              backgroundColor: color,
              color: textColor,
            )),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => route()));
        },
      ),
    );
  }
}
