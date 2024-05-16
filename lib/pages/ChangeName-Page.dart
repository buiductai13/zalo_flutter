// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:zalochat/models/userModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeNameScreen extends StatefulWidget {
  final UserModel userModel;

  const ChangeNameScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  _ChangeNameScreenState createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  late TextEditingController _fullNameController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thay đổi họ và tên'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Họ và tên mới'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updateFullName(),
              child: const Text('Cập nhật họ và tên'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateFullName() async {
    String newFullName = _fullNameController.text.trim();

    if (newFullName.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userModel.uid)
            .update({'fullname': newFullName});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tên của bạn đã được cập nhật!'),
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error updating full name: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating full name. Please try again.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new full name'),
        ),
      );
    }
  }
}
