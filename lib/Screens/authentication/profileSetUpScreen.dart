import 'dart:developer';
import 'dart:io';

import 'package:chat_app/model/chatlist.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chat_app/Screens/chatlist/BottomNavigation.dart';

class ProfileSetupScreen extends StatefulWidget {
  final User user;
  final UserModel userModel;
  final User firebaseUser;
  const ProfileSetupScreen(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      required this.user});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _phoneController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

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

  Future<void> _saveProfile() async {
    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(_profileImage!);
      }
      String? fullname = _nameController.text.trim();
      // String? mobileNo = _phoneController.text.trim();
      // Update UserModel with new data
      widget.userModel.name = fullname;
      widget.userModel.profileImageUrl = profileImageUrl ?? '';
      // widget.userModel. = fcmToken ?? '';

      // Get current FCM token or generate a new one if none exists
      String fcmToken = await GetStorage().read('fcm');
      log("vbhbhgbhbhjhbnjn $fcmToken");
      // await _firestore.collection('users').doc(widget.user.uid).update({
      //   'name': _nameController.text.trim(),
      //   // 'phone': _phoneController.text.trim(),
      //   'profileImageUrl': profileImageUrl ?? '',
      //   'fcmToken': fcmToken,
      // });
      await _firestore.collection('users').doc(widget.userModel.uid).update({
        'name': _nameController.text.trim(),
        // 'phone': _phoneController.text.trim(),
        'profileImageUrl': profileImageUrl ?? '',
        'fcmToken': fcmToken,
      });

      // await FirebaseFirestore.instance
      //     .collection("users")
      //     .doc(widget.userModel.uid)
      //     .set(widget.userModel!.toMap())
      //     .then((value) {
      //   print("data uploaded.........................");
      // });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BottomNavigation(
            userModel: widget.userModel,
            firebaseUser: widget.firebaseUser,
          ),
        ),
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
            // TextField(
            //   controller: _phoneController,
            //   keyboardType: TextInputType.number,
            //   decoration: const InputDecoration(
            //     labelText: "Phone Number",
            //     border: OutlineInputBorder(),
            //   ),
            // ),
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
