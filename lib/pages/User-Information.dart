// ignore_for_file: file_names, avoid_print, unnecessary_null_comparison

import "dart:io";

import "package:zalochat/models/userModel.dart";
import "package:zalochat/pages/ChangeName-Page.dart";
import "package:zalochat/pages/ChangePass-Page.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key, required this.userModel}) : super(key: key);
  final UserModel userModel;
  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? imageFile;
  User? _user;
  String? _fullName;
  String? _profileImageUrl;

  bool showSettings = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void checkValues() {
    if (imageFile == null) {
      print("Xin hãy chọn ảnh trước");
    } else {
      _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    User? user = _auth.currentUser;
    if (user != null && imageFile != null) {
      try {
        // Upload image to Firebase Storage
        UploadTask uploadTask =
            _storage.ref('profilepictures/${user.uid}.jpg').putFile(imageFile!);

        // Get the updated download URL
        String imageUrl = await (await uploadTask).ref.getDownloadURL();

        // Update Firestore document with the new profile picture URL
        await FirebaseFirestore.instance
            .collection(
                'users') // Replace 'users' with your Firestore collection name
            .doc(user.uid)
            .update({'profilepicture': imageUrl});

        setState(() {
          _profileImageUrl = imageUrl;
        });
      } catch (error) {
        print('Lỗi upload hình: $error');
      }
    }
  }

  Future<void> _getUserInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Retrieve additional user information from Firestore
      DocumentSnapshot<Map<String, dynamic>> userInfo =
          await _firestore.collection('users').doc(user.uid).get();

      setState(() {
        _user = user;
        _fullName = userInfo.data()?['fullname'];
        _profileImageUrl = userInfo.data()?['profilepicture'];
      });
    }
  }

  void _settingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cài đặt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  if (widget.userModel != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeNameScreen(userModel: widget.userModel),
                      ),
                    );
                  } else {
                    print("widget.userModel is null");
                  }
                },
                title: const Text("Đổi tên"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePassword(),
                    ),
                  );
                },
                title: const Text("Đổi mật khẩu"),
              ),
            ],
          ),
        );
      },
    );
  }

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    ImageCropper imageCropper = ImageCropper();
    CroppedFile? croppedImage = (await imageCropper.cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    ));

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Thay đổi ảnh đại diện"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Chọn ảnh từ thư viện"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Chụp một tấm hình"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(60),
                  ),
                  onPressed: () {
                    checkValues();
                  },
                  child: const Text(
                    'Xác nhận đăng hình',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              _settingDialog();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200.0,
            decoration: const BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                image: NetworkImage(
                    'https://media.istockphoto.com/id/838406396/vector/chat-bot-and-bubble-seamless-pattern.jpg?s=612x612&w=0&k=20&c=_qJrmFqCqBCHgZHvNFhkwi8dZgIgNcpRbroeCAjTKtk='),
                fit: BoxFit.cover,
              ),
            ),
            child: _user != null
                ? CupertinoButton(
                    onPressed: () {
                      showPhotoOptions();
                    },
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      backgroundColor: const Color.fromARGB(255, 83, 81, 81),
                    ),
                  )
                : Container(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _user != null
                ? Text(
                    'Tên: $_fullName',
                    style: const TextStyle(fontSize: 18),
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}
