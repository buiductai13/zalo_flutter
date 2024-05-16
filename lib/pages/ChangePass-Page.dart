// ignore_for_file: file_names, avoid_print, unrelated_type_equality_checks

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:zalochat/components/PasswordTextField.dart";

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String _errorMessage = '';
  void checkValues() {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    if (currentPassword == "" || newPassword == "") {
      print("Vui lòng đừng để trống các ô!");
    } else {
      _changePassword();
    }
  }

  void _changePassword() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Ủy quyền truy cập của người dùng (để lấy mật khẩu)
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);

        // Thay đổi mật khẩu
        await user.updatePassword(_newPasswordController.text);

        // Đổi mật khẩu thành công
        _showSuccessDialog();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Lỗi: $error';
      });
      print('Lỗi thay đổi mật khẩu: $error');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hoàn thành'),
          content: const Text('Đã thay đổi mật khẩu thành công.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyPasswordTextField(
                  controller: _currentPasswordController,
                  myText: "Mật khẩu hiện tại"),
              MyPasswordTextField(
                  controller: _newPasswordController,
                  myText: "Mật khẩu mới"),
              const SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(60),
                  ),
                  child: const Text("XÁC NHẬN ĐỔI MẬT KHẨU",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      checkValues();
                    }
                  },
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
