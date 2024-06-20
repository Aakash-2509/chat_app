import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  String? _fullName;
  String? _phoneNumber;
  String? _photoUrl;
  Box? _imageBox;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _initHive();
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

  Future<void> _initHive() async {
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    _imageBox = await Hive.openBox('images');
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _fullName = userDoc.get('name');
          _phoneNumber = userDoc.get('phone');
          _photoUrl = userDoc.get('profileImageUrl');
          _loadImageLocally();
        });
      } else {
        setState(() {
          _fullName = 'No name';
          _phoneNumber = 'No phone number';
          _photoUrl = null;
        });
      }
    }
  }

  Future<void> _loadImageLocally() async {
    if (_photoUrl != null) {
      final imageData = await _imageBox?.get(_user!.uid);
      if (imageData != null) {
        setState(() {
          _photoUrl = imageData;
        });
      } else {
        await _downloadAndStoreImage();
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        String downloadUrl = await _uploadImage(imageFile);
        await _firestore.collection('users').doc(_user!.uid).update({
          'profileImageUrl': downloadUrl,
        });
        _imageBox?.put(_user!.uid, downloadUrl);
        setState(() {
          _photoUrl = downloadUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<String> _uploadImage(File image) async {
    Reference storageReference = _storage.ref().child(
        'profile_images/${_user!.uid}/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  Future<void> _downloadAndStoreImage() async {
    final imageUrl = await _storage.refFromURL(_photoUrl!).getDownloadURL();
    _imageBox?.put(_user!.uid, imageUrl);
    setState(() {
      _photoUrl = imageUrl;
    });
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
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : const AssetImage('assets/default_images/trainer.png')
                          as ImageProvider,
                  child: _photoUrl == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
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
                    _photoUrl = null;
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
