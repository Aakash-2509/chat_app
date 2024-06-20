import 'dart:io';

import 'package:chat_app/Screens/chatlist/BottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSetupScreen extends StatefulWidget {
  final User user;
  const ProfileSetupScreen({super.key, required this.user});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage(File image) async {
    Reference storageReference = _storage.ref().child(
        'profile_images/${widget.user.uid}/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  void _saveProfile() async {
    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      }

      await _firestore.collection('users').doc(widget.user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'profileImageUrl': profileImageUrl ?? '',
      });

      // Navigate to the home screen or another appropriate screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BottomNavigation()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set up your profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
