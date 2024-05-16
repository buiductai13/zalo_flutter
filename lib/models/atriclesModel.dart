// ignore_for_file: unused_import, unnecessary_this

import 'dart:io';

class Post {
  late String avatarUrl;
  late String authorName;
  late String content;
  late String imageFileUrl;
  late int likes;
  late bool initialLikes;
  late List<Comment> comments;
  late int timestamp;

  Post({
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
  final String authorName;
  final String text;

  Comment({
    required this.authorName,
    required this.text,
  });
}
