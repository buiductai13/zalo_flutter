// ignore_for_file: library_private_types_in_public_api, file_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zalochat/models/userModel.dart';

class OtherUserScreen extends StatefulWidget {
  const OtherUserScreen({
    Key? key,
    required this.targetUser,
    required this.userModel,
  }) : super(key: key);
  final UserModel targetUser;
  final UserModel userModel;

  @override
  _OtherUserScreenState createState() => _OtherUserScreenState();
}

class _OtherUserScreenState extends State<OtherUserScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String? _fullName;
  String? _profileImageUrl;
  bool isRequestSent = false;
  bool areFriends = false;
  String requestId = '';

  // Thu hồi lời mời nếu cả hai đã là bạn bè
  Future<void> retractFriendRequest(UserModel targetUser) async {
    try {
      // Find the friend request sent to the target user by the current user
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('friend_requests')
              .where('senderId', isEqualTo: widget.userModel.uid)
              .where('receiverId', isEqualTo: targetUser.uid)
              .get();

      // Check if there are any matching friend requests
      if (querySnapshot.docs.isNotEmpty) {
        // Retrieve the friend request document
        DocumentSnapshot<Map<String, dynamic>> friendRequestDocument =
            querySnapshot.docs.first;

        // Retrieve the document ID (requestId) and delete the document
        String requestId = friendRequestDocument.id;
        await FirebaseFirestore.instance
            .collection('friend_requests')
            .doc(requestId)
            .delete();

        print('Friend request retracted.');
      } else {
        print('No friend requests found for retraction.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

// Xóa kết bạn
  Future<void> unfriend() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.uid)
        .update({
      'friendList': FieldValue.arrayRemove([widget.targetUser.uid]),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.targetUser.uid)
        .update({
      'friendList': FieldValue.arrayRemove([widget.userModel.uid]),
    });

    setState(() {
      areFriends = false;
    });
  }

  // Kiểm tra nếu cả hai có phải là bạn bè
  Future<bool> areUsersFriends() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userModel.uid)
            .get();

    dynamic friendListData = documentSnapshot['friendList'];
    List<dynamic> friendList =
        (friendListData is List) ? friendListData : [friendListData];

    return friendList.contains(widget.targetUser.uid);
  }

  // Hiển thị thông báo cho việc xóa kết bạn
  Future<void> showUnfriendDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy kết bạn'),
          content: Text(
              'Bạn có chác chắn muốn hủy kết bạn với $_fullName không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                unfriend();
                Navigator.of(context).pop();
              },
              child: const Text('Hủy kết bạn'),
            ),
          ],
        );
      },
    );
  }

  // Kiểm tra nếu lời mời đã được gửi
  Future<bool> checkFriendRequestExists() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('friend_requests')
        .where('senderId', isEqualTo: widget.userModel.uid)
        .where('receiverId', isEqualTo: widget.targetUser.uid)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Gửi kết bạn
  Future<void> sendFriendRequest() async {
    await FirebaseFirestore.instance.collection('friend_requests').add({
      'senderId': widget.userModel.uid,
      'receiverId': widget.targetUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Kiểm tra nếu lời mời kết bạn đã gửi chưa
    checkFriendRequestExists().then((exists) {
      setState(() {
        isRequestSent = exists;
      });
    });
    // Kiểm tra xem người dùng đã là bạn hay chưa
    areUsersFriends().then((friends) {
      setState(() {
        areFriends = friends;
      });
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _fullName = widget.targetUser.fullname;
      _profileImageUrl = widget.targetUser.profilepicture;
    });
  }

  Widget _buildUserInfoContainer() {
    return Container(
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
              onPressed: () {},
              child: CircleAvatar(
                radius: 100,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                backgroundColor: Colors.grey,
              ),
            )
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserInfoContainer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _user != null
                ? Text(
                    'Tên: $_fullName',
                    style: const TextStyle(fontSize: 18),
                  )
                : Container(),
          ),
          ElevatedButton(
            onPressed: () async {
              if (areFriends) {
                // If already friends, perform the action for friends
                // For example, navigate to a friend's profile, etc.
                // You can customize this part based on your application logic.
                print('Các bạn đã là bạn bè');
                showUnfriendDialog();
              } else {
                if (isRequestSent) {
                  // If request already sent, retract the request
                  await retractFriendRequest(widget.targetUser);
                  setState(() {
                    isRequestSent = false;
                  });
                } else {
                  // If not friends and request not sent, send the request
                  await sendFriendRequest();
                  setState(() {
                    isRequestSent = true;
                  });
                }
              }
            },
            child: Text(
              areFriends
                  ? 'Đã là bạn bè'
                  : (isRequestSent ? 'Thu hồi lời mời' : 'Gửi kết bạn'),
            ),
          )
        ],
      ),
    );
  }
}
