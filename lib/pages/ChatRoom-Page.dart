// ignore_for_file: file_names, avoid_unnecessary_containers, avoid_print

import 'package:zalochat/database/database.dart';
import 'package:zalochat/models/chatRoomModel.dart';
import 'package:zalochat/models/messageModel.dart';
import 'package:zalochat/models/userModel.dart';
import 'package:zalochat/pages/Main-Page.dart';
import 'package:zalochat/pages/OtherUserInfo-Page.dart';
import 'package:zalochat/pages/Search-Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {Key? key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  void sendMessage() async {
    // ignore: unused_local_variable
    String msg = messageController.text.trim();

    if (msg != "") {
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now().toString(),
        text: msg,
        seen: false,
      );
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
      print("Đã gửi tin nhắn ");
    }
  }

  final _myBox = Hive.box('mybox');
  BlockMessDataBase db = BlockMessDataBase();

  @override
  void initState() {
    // if this is the 1st time ever openin the app, then create default data
    if (_myBox.get("BLOCK") == null) {
      db.createInitialData(widget.userModel.uid!, widget.targetUser.uid!);
    } else {
      // there already exists data
      db.loadData();
    }
    checkBlock();

    super.initState();
  }

  String? selectedMenu;
  bool isBlock = false;
  bool isBlocked = false;

  void addListBlock() {
    if (db.data.isEmpty) {
      db.data.add([widget.userModel.uid, widget.targetUser.uid, true]);
    } else {
      bool elementExists = false;
      for (int i = 0; i < db.data.length; i++) {
        if (widget.userModel.uid == db.data[i][0] &&
            widget.targetUser.uid == db.data[i][1]) {
          db.data[i][2] = true;
          elementExists = true;
          setState(() {});
          break;
        }
      }
      if (!elementExists) {
        // Nếu không có phần tử nào có cùng 2 phần tử đầu
        db.data.add([
          widget.userModel.uid,
          widget.targetUser.uid,
          true
        ]); // Thêm một list mới
      }
    }
  }

  void checkBlock() {
    bool newBlock = false;
    for (int i = 0; i < db.data.length; i++) {
      if (widget.userModel.uid != db.data[i][0] &&
          widget.targetUser.uid != db.data[i][1]) {
        isBlock = false;
        isBlocked = false;
        setState(() {});
      }
    }
    for (int i = 0; i < db.data.length; i++) {
      if (widget.userModel.uid == db.data[i][1] &&
          widget.targetUser.uid == db.data[i][0]) {
        isBlocked = db.data[i][2];
        newBlock = isBlocked;
        setState(() {});
      }
    }
    for (int i = 0; i < db.data.length; i++) {
      if (widget.userModel.uid == db.data[i][0] &&
          widget.targetUser.uid == db.data[i][1]) {
        isBlock = db.data[i][2];
        isBlocked = newBlock;
        setState(() {});
      }
    }
    print(isBlock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MainPage(
                userModel: widget.userModel,
                firebaseUser: widget.firebaseUser,
              );
            }));
          },
        ),
        title: isBlock
            ? Row(children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      NetworkImage(widget.targetUser.profilepicture.toString()),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(widget.targetUser.fullname.toString()),
              ])
            : Row(
                children: [
                  Expanded(
                    child: Row(children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        backgroundImage: NetworkImage(
                            widget.targetUser.profilepicture.toString()),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(widget.targetUser.fullname.toString()),
                    ]),
                  ),
                  PopupMenuButton<String>(
                      initialValue: selectedMenu,
                      onSelected: (item) {
                        setState(() {
                          selectedMenu = item;
                        });
                        print(selectedMenu);
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                            PopupMenuItem(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OtherUserScreen(
                                              targetUser: widget.targetUser,
                                              userModel: widget.userModel)));
                                },
                                child: const Text("Thông tin người dùng")),
                            PopupMenuItem(
                                onTap: () {
                                  addListBlock();
                                  checkBlock();
                                  db.updateDataBase();
                                },
                                child: const Text("Chặn tin nhắn")),
                          ])
                ],
              ),
      ),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMesage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            return Row(
                              mainAxisAlignment:
                                  (currentMesage.sender == widget.userModel.uid)
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: (currentMesage.sender ==
                                                widget.userModel.uid)
                                            ? Colors.grey
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      currentMesage.text.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    )),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              'Không thể kết nối vui lòng kiểm tra kết nối internet'),
                        );
                      } else {
                        return const Center(
                          child: Text("Hãy gửi lời chào đến bạn mới"),
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
            ),
            isBlock
                ? RichText(
                    text: TextSpan(children: [
                    const TextSpan(
                        text: "Bạn đã chặn người dùng này. ",
                        style: TextStyle(color: Colors.black)),
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            for (int i = 0; i < db.data.length; i++) {
                              if (widget.userModel.uid == db.data[i][0] &&
                                  widget.targetUser.uid == db.data[i][1]) {
                                db.data[i][2] = false;
                                setState(() {});
                                break;
                              }
                            }
                            checkBlock();
                            db.updateDataBase();
                          },
                        text: "Bỏ chặn",
                        style: const TextStyle(color: Colors.blue))
                  ]))
                : isBlocked
                    ? const Text("Bạn đã bị người dùng này chặn tin nhắn")
                    : Container(
                        color: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Flexible(
                              child: TextField(
                                controller:
                                    messageController, // Added 'text' property
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Tin nhắn ",
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                sendMessage();
                              },
                              icon: Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            )
                          ],
                        ),
                      )
          ],
        ),
      )),
    );
  }
}
