// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:zalochat/models/chatRoomModel.dart';
import 'package:zalochat/models/firebaseHelper.dart';
import 'package:zalochat/models/userModel.dart';
import 'package:zalochat/pages/ChatRoom-Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const ChatPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("participants.${widget.userModel.uid}", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                      chatRoomSnapshot.docs[index].data()
                          as Map<String, dynamic>,
                    );

                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;
                    List<String> participantKeys = participants.keys.toList();
                    participantKeys.remove(widget.userModel.uid);

                    return FutureBuilder(
                      future: FirebaseHelper.getUserModelById(
                        participantKeys[0],
                      ),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;

                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return ChatRoomPage(
                                      chatroom: chatRoomModel,
                                      firebaseUser: widget.firebaseUser,
                                      userModel: widget.userModel,
                                      targetUser: targetUser,
                                    );
                                  }),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    targetUser.profilepicture.toString()),
                              ),
                              title: Text(targetUser.fullname.toString()),
                              subtitle:
                                  Text(chatRoomModel.lastMessage.toString()),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return const Center(
                  child: Text("Không có tin nhắn"),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
