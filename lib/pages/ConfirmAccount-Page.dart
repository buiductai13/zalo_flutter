// ignore_for_file: file_names, avoid_print

import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:zalochat/components/NameTextField.dart";
import "package:zalochat/models/userModel.dart";
import "package:zalochat/pages/Main-Page.dart";

// ignore: must_be_immutable
class ConfirmAccount extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  TextEditingController fullNameController = TextEditingController();

  ConfirmAccount(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);
  @override
  State<ConfirmAccount> createState() => _ConfirmAccountState();
}

class _ConfirmAccountState extends State<ConfirmAccount> {
  File? imageFile;

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
            title: const Text("Chọn ảnh đại diện"),
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
                )
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullname = widget.fullNameController.text.trim();
    if (fullname == "" || imageFile == null) {
      print("Làm ơn hãy điền đầy đủ thông tin!");
    } else {
      print("Đang cập nhật");
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = widget.fullNameController.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepicture = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print("đang cập nhật");
      print("Đã cập nhật thành công!");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MainPage(
          firebaseUser: widget.firebaseUser,
          userModel: widget.userModel,
        );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent.shade700,
          title: const Text(
            "Hoàn tất đăng ký",
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
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                CupertinoButton(
                  onPressed: () {
                    showPhotoOptions();
                  },
                  child: CircleAvatar(
                    backgroundImage:
                        (imageFile != null) ? FileImage(imageFile!) : null,
                    radius: 60,
                    child: (imageFile == null)
                        ? const Icon(
                            Icons.person,
                            size: 60,
                          )
                        : null,
                  ),
                ),
                MyNameTextField(
                  controller: widget.fullNameController,
                  name: "Họ và tên",
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.shade700,
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(60),
                  ),
                  child: const Text("XÁC NHẬN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  onPressed: () {
                    checkValues();
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
