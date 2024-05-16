// ignore_for_file: use_key_in_widget_constructors, unused_element, prefer_const_constructors, use_build_context_synchronously, unnecessary_null_comparison, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, library_private_types_in_public_api, unused_import
import 'package:zalochat/models/userModel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class History extends StatefulWidget {
  final UserModel userModel;

  const History({super.key, required this.userModel});
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool isSearchActivated = false;
  String searchText = '';
  List<Post> posts = [];
  late TextEditingController postController;
  File? selectedImage;
  bool _isExpanded = false;

  void _toggleImageSize() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void initState() {
    super.initState();
    postController = TextEditingController();
    _getPosts();
  }

  void deletePost(int index) async {
    try {
      // Kiểm tra xem tài liệu có tồn tại trước khi cố gắng xóa
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(posts[index].timestamp.toString())
          .get();

      if (postSnapshot.exists) {
        // Tài liệu tồn tại, tiếp tục xóa
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(posts[index].timestamp.toString())
            .delete();
        setState(() {
          posts.removeAt(index);
        });
      } else {
        print("Tài liệu không tồn tại.");
      }
    } catch (e) {
      print("Lỗi khi xóa bài viết: $e");
    }
  }

  void editPost(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chỉnh sửa bài viết'),
          content: TextField(
            controller: TextEditingController(text: posts[index].content),
            onChanged: (value) {
              setState(() {
                posts[index].content = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Nhập nội dung bài viết...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // Kiểm tra xem tài liệu có tồn tại trước khi cố gắng cập nhật
                  DocumentSnapshot postSnapshot = await FirebaseFirestore
                      .instance
                      .collection('posts')
                      .doc(posts[index].timestamp.toString())
                      .get();

                  if (postSnapshot.exists) {
                    // Tài liệu tồn tại, tiếp tục cập nhật
                    final newContent = posts[index].content;
                    final timestamp = posts[index].timestamp;

                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(timestamp.toString())
                        .update({'content': newContent});

                    Navigator.of(context).pop();
                  } else {
                    print("Tài liệu không tồn tại.");
                  }
                } catch (e) {
                  print("Lỗi khi cập nhật bài viết: $e");
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    String postText = postController.text;
    String? imageUrl;

    if (selectedImage != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('image_$timestamp.jpg');
      await ref.putFile(selectedImage!);
      imageUrl = await ref.getDownloadURL();
    }

    final newPost = Post(
      isHide: false,
      postId: "",
      avatarUrl: widget.userModel.profilepicture!,
      authorName: widget.userModel.fullname!,
      content: postText,
      imageFileUrl: imageUrl ?? "",
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    DocumentReference postRef =
        await FirebaseFirestore.instance.collection('posts').add({
      'hide': false,
      'avatarUrl': newPost.avatarUrl,
      'authorName': newPost.authorName,
      'content': newPost.content,
      'imageFileUrl': imageUrl,
      'likes': newPost.likes,
      'initialLikes': newPost.initialLikes,
      'comments': newPost.comments.map((comment) {
        return {
          'authorName': comment.authorName,
          'text': comment.text,
        };
      }).toList(),
      'timestamp': newPost.timestamp,
    });

    newPost.postId = postRef.id;

    setState(() {
      posts.insert(0, newPost);
      postController.clear();
      selectedImage = null;
    });
  }

  Future<void> _getPosts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .get();

    final List<Post> fetchedPosts = querySnapshot.docs.map((doc) {
      final String postId = doc.id;
      final bool? isHide = doc.data()['hide'];
      final String? avatarUrl = doc.data()['avatarUrl'];
      final String? authorName = doc.data()['authorName'];
      final String? content = doc.data()['content'];
      final String? imageFileUrl = doc.data()['imageFileUrl'];
      final int? likes = doc.data()['likes'];
      final bool? initialLikes = doc.data()['initialLikes'];
      final List<dynamic>? commentsData = doc.data()['comments'];
      final int? timestamp = doc.data()['timestamp'];

      final List<Comment> comments = commentsData != null
          ? commentsData.map<Comment>((comment) {
              return Comment(
                authorName: comment['authorName'] ?? '',
                text: comment['text'] ?? '',
              );
            }).toList()
          : [];

      return Post(
        postId: postId,
        isHide: isHide ?? false,
        avatarUrl: avatarUrl ?? '',
        authorName: authorName ?? '',
        content: content ?? '',
        imageFileUrl: imageFileUrl ?? '',
        likes: likes ?? 0,
        initialLikes: initialLikes ?? false,
        comments: comments,
        timestamp: timestamp ?? 0,
      );
    }).toList();

    posts = fetchedPosts;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  void addComment(int index, String text) {
    setState(() {
      final comment = Comment(
        authorName: widget.userModel.fullname!,
        text: text,
      );
      posts[index].comments.add(comment);
    });
  }

  void showComments(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bình luận'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final comment in posts[index].comments)
                ListTile(
                  title: Text(comment.authorName),
                  subtitle: Text(comment.text),
                ),
              TextField(
                onSubmitted: (text) {
                  addComment(index, text);
                  Navigator.of(context).pop();
                },
                decoration: InputDecoration(
                  hintText: 'Thêm bình luận...',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //add like
  void updateLikesInFirestore(
      int index, bool isLike, String id, int likes) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(id)
          .update({'initialLikes': isLike, "likes": likes});
    } catch (e) {
      print("Lỗi khi cập nhật số lượt thích: $e");
    }
    setState(() {});
  }

  //hide post
  void hidePost(int index, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(id)
          .update({'hide': true});
    } catch (e) {
      print("Lỗi khi cập nhật số lượt thích: $e");
    }
    setState(() {});
  }

  void reHidePost(int index, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(id)
          .update({'hide': false});
    } catch (e) {
      print("Lỗi khi cập nhật số lượt thích: $e");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 15),
                CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      NetworkImage(widget.userModel.profilepicture!),
                ),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  height: 70,
                  width: 270,
                  child: TextField(
                    controller: postController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung bài đăng...',
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        getImage();
                      },
                      borderRadius: BorderRadius.circular(21),
                      child: Ink(
                        height: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(21),
                            color: Color.fromARGB(255, 246, 240, 240)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_rounded,
                                size: 23,
                                color: Colors.green,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text('Đăng ảnh'),
                            ]),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        _submitForm();
                      },
                      borderRadius: BorderRadius.circular(21),
                      child: Ink(
                        height: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(21),
                            color: Color.fromARGB(255, 246, 240, 240)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.post_add_rounded,
                                size: 23,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text('Đăng bài'),
                            ]),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(21),
                      child: Ink(
                        height: 35,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(21),
                            color: Color.fromARGB(255, 246, 240, 240)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_camera_back_outlined,
                                size: 23,
                                color: Colors.deepPurpleAccent[700],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text('Tạo album'),
                            ]),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              height: 10,
              color: Color.fromARGB(255, 236, 236, 236),
            ),
            if (selectedImage != null)
              Container(
                width: screenWidth,
                child: Image.file(selectedImage!, fit: BoxFit.cover),
              ),
            SizedBox(
              height: 800,
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Color.fromARGB(255, 236, 236, 236),
                  thickness: 10.0,
                  height: 0,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return posts[index].isHide
                      ? Container(
                          child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 20, top: 10, left: 10, right: 10),
                          child: RichText(
                              text: TextSpan(children: [
                            const TextSpan(
                                text: "Bài viết đã bị ẩn .",
                                style: TextStyle(color: Colors.black)),
                            TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    reHidePost(index, posts[index].postId);
                                    _getPosts();
                                    setState(() {});
                                  },
                                text: "Hiển thị lại bài viết",
                                style: const TextStyle(color: Colors.blue))
                          ])),
                        ))
                      : Column(children: [
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 8), // Add left padding here
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(post.avatarUrl),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post.authorName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      formatTimestamp(post.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      editPost(index);
                                    } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Xác nhận xóa'),
                                            content: Text(
                                                'Bạn có chắc muốn xóa bài viết này?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  deletePost(index);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Xóa'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Hủy'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else if (value == 'hide') {
                                      hidePost(index, posts[index].postId);
                                      _getPosts();
                                      setState(() {});
                                    } else if (value == 'report') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Báo cáo!'),
                                            content: Text(
                                                'Bạn đã báo cáo thành công'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Đóng'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else if (value == "reHide") {
                                      reHidePost(index, posts[index].postId);
                                      _getPosts();
                                      setState(() {});
                                    }
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Chỉnh sửa bài viết'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Xóa bài viết'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'report',
                                      child: Text('Báo cáo bài viết'),
                                    ),
                                    PopupMenuItem<String>(
                                      value: posts[index].isHide
                                          ? 'reHide'
                                          : 'hide',
                                      child: Text(posts[index].isHide
                                          ? "Hiện bài viết"
                                          : 'Ẩn bài viết'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding:
                                EdgeInsets.only(left: 12, top: 10, bottom: 8),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              post.content,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          (post.imageFileUrl != null &&
                                  post.imageFileUrl.isNotEmpty)
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    width: screenWidth,
                                    height: _isExpanded
                                        ? MediaQuery.of(context).size.height
                                        : 350,
                                    child: Image.network(
                                      post.imageFileUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  post.initialLikes
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: post.initialLikes ? Colors.red : null,
                                ),
                                onPressed: () {
                                  bool isLike = posts[index].initialLikes;
                                  int likes = posts[index].likes;
                                  if (isLike) {
                                    isLike = false;
                                    likes = likes - 1;
                                    setState(() {});
                                  } else {
                                    isLike = true;
                                    likes = likes + 1;
                                    setState(() {});
                                  }
                                  updateLikesInFirestore(index, isLike,
                                      posts[index].postId, likes);
                                  setState(() {});
                                  _getPosts();
                                },
                              ),
                              Text('${post.likes} Thích'),
                              SizedBox(
                                width: 20,
                              ),
                              IconButton(
                                icon: Icon(Icons.comment),
                                onPressed: () {
                                  showComments(index);
                                },
                              ),
                              Text('${post.comments.length} Bình luận'),
                            ],
                          ),
                          SizedBox(height: 12),
                        ]);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void showSearchBar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tìm kiếm'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                searchText = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Nhập từ khóa',
              border: InputBorder.none,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isSearchActivated = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}

class Post {
  late String postId;
  late String avatarUrl;
  late String authorName;
  late String content;
  late String imageFileUrl;
  late int likes;
  late bool initialLikes;
  late List<Comment> comments;
  late int timestamp;
  late bool isHide;

  Post({
    required this.isHide,
    required this.postId,
    required this.avatarUrl,
    required this.authorName,
    required this.content,
    required this.imageFileUrl,
    this.likes = 0,
    this.initialLikes = false,
    this.comments = const [],
    required this.timestamp,
  });
}

class Comment {
  late String authorName;
  late String text;

  Comment({
    required this.authorName,
    required this.text,
  });
}

String formatTimestamp(int timestamp) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  // Định dạng thời gian ở đây (ví dụ: "dd/MM/yyyy HH:mm")
  String formattedTime =
      "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  return formattedTime;
}
