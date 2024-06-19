import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _fullName;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _fetchUserData();
    }
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
        if (_user != null) {
          _fetchUserData();
        }
      });
    });
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _fullName = userDoc.get('name');
          _phoneNumber = userDoc.get('phoneNumber');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/default_profile_image.jpg'), // Placeholder image
                // You can use Firebase storage or network image here based on user profile photo URL
              ),
              const SizedBox(height: 16),
              Text(
                _fullName ?? 'Loading...',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _user?.email ?? 'No email',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(
                  _phoneNumber ?? 'No phone number',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  setState(() {
                    _user = null;
                    _fullName = null;
                    _phoneNumber = null;
                  });
                },
                child: const Text("Log Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
