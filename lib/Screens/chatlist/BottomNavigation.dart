import 'package:chat_app/Screens/chatlist/HomePage.dart';
import 'package:chat_app/Screens/chatlist/profileScreen.dart';
import 'package:chat_app/Screens/chatlist/searchPage.dart';
import 'package:chat_app/model/chatlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  //  final UserModel userModel;
  // final User firebaseUser; 
    const BottomNavigation({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;
    late final List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      HomePage(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
      const ProfileTab(),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: const Text('Setoo Chat App'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
