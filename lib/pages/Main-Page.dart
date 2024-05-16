// ignore_for_file: file_names, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:zalochat/pages/Articles_Page.dart';
import 'package:zalochat/pages/Chat-Page.dart';
import 'package:zalochat/pages/FriendList.dart';
import 'package:zalochat/pages/Home-Page.dart';
import 'package:zalochat/pages/Notification-Page.dart';
import 'package:zalochat/pages/Search-Page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zalochat/models/userModel.dart';
import 'package:zalochat/pages/User-Information.dart';

class MainPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MainPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ChatPage(
        userModel: widget.userModel,
        firebaseUser: widget.firebaseUser,
      ),
      FriendListScreen(userModel: widget.userModel),
      History(
        userModel: widget.userModel,
      ),
      FriendRequestScreen(currentUser: widget.userModel),
      ProfilePage(
        userModel: widget.userModel,
      ),
    ];
  }

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tìm kiếm',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[300],
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.search,
            size: 26.0,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SearchPage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser);
            }));
            // Thực hiện hành động tìm kiếm
          },
        ),
        toolbarHeight: 42.0,
        actions: [
          // Thêm icon mã QR
          IconButton(
            icon: const Icon(Icons.qr_code, size: 26.0),
            color: Colors.white,
            onPressed: () {
              // Thực hiện hành động khi nhấn vào icon mã QR
            },
          ),
          // Thêm icon dấu +
          IconButton(
            icon: const Icon(Icons.add, size: 31.0),
            color: Colors.white,
            onPressed: () {
              // Thực hiện hành động khi nhấn vào icon dấu +
            },
          ),
          IconButton(
            // Thực hiện hành động đăng xuất
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return HomePage();
                }),
              );
            },
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chats',
            backgroundColor: Colors.blueAccent,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Contacts',
            backgroundColor: Colors.blueAccent,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Moments',
            backgroundColor: Colors.blueAccent,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
            backgroundColor: Colors.blueAccent,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}

class ContactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Contacts Page'),
    );
  }
}

class MomentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Moments Page'),
    );
  }
}
