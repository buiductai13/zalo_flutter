// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print

import 'package:zalochat/pages/OtherUserInfo-Page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zalochat/models/userModel.dart';

class FriendListScreen extends StatefulWidget {
  final UserModel userModel;

  const FriendListScreen({super.key, required this.userModel});

  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late List<UserModel> friendList;

  @override
  void initState() {
    super.initState();
    friendList = [];
    fetchFriendList();
  }

  Future<void> fetchFriendList() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userModel.uid)
              .get();

      List<dynamic> friendUids = documentSnapshot['friendList'] ?? [];

      List<UserModel> friends = [];

      for (String friendUid in friendUids) {
        DocumentSnapshot<Map<String, dynamic>> friendSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(friendUid)
                .get();

        if (friendSnapshot.exists) {
          UserModel friend = UserModel.fromMap(friendSnapshot.data()!);
          friends.add(friend);
        }
      }

      setState(() {
        friendList = friends;
      });
    } catch (e) {
      print('Error fetching friend list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        automaticallyImplyLeading: false,
      ),
      body: friendList.isNotEmpty
          ? ListView.builder(
              itemCount: friendList.length,
              itemBuilder: (context, index) {
                UserModel friend = friendList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend.profilepicture!),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtherUserScreen(
                          targetUser: friend,
                          userModel: widget.userModel,
                        ),
                      ),
                    );
                  },
                  title: Text(friend.fullname!),
                );
              },
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bạn không có bạn bè.",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Hãy bắt đầu kết bạn nào!",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
