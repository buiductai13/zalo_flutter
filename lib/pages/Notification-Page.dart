// ignore_for_file: file_names

import 'package:zalochat/models/userModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequestScreen extends StatelessWidget {
  final UserModel currentUser;

  const FriendRequestScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('receiverId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Không có thông báo nào'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var request = snapshot.data!.docs[index];

              // Assuming 'users' is the collection where user information is stored
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(request['senderId'])
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // or a loading indicator
                  }

                  var userData = userSnapshot.data!.data();
                  var senderFullName = userData!['fullname'];

                  return ListTile(
                    title: Text(
                        'Bạn có lời mời kết bạn từ $senderFullName'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Update status to 'accepted' in Firebase
                            await FirebaseFirestore.instance
                                .collection('friend_requests')
                                .doc(request.id)
                                .update({'status': 'accepted'});

                            // Add users to each other's friend lists
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .update({
                              'friendList':
                                  FieldValue.arrayUnion([request['senderId']])
                            });

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(request['senderId'])
                                .update({
                              'friendList':
                                  FieldValue.arrayUnion([currentUser.uid])
                            });
                            FirebaseFirestore.instance
                                .collection('friend_requests')
                                .doc(request.id)
                                .delete();
                          },
                          child: const Text('Accept'),
                        ),
                        const SizedBox(width: 8), // Add spacing between buttons
                        ElevatedButton(
                          onPressed: () {
                            // Delete the friend request document from Firebase
                            FirebaseFirestore.instance
                                .collection('friend_requests')
                                .doc(request.id)
                                .delete();
                          },
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
