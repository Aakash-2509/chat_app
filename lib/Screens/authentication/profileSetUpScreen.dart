// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';

// class ProfileSetupScreen extends StatefulWidget {
//   const ProfileSetupScreen({super.key});

//   @override
//   _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
// }

// class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   File? _image;

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _image = File(image.path);
//       });
//     }
//   }

//   Future<void> _saveProfile() async {
//     try {
//       User? user = _auth.currentUser;
//       String? imageUrl;

//       if (_image != null) {
//         final storageRef = _storage.ref().child('user_photos/${user!.uid}.jpg');
//         await storageRef.putFile(_image!);
//         imageUrl = await storageRef.getDownloadURL();
//       }

//       await user!.updateDisplayName(_nameController.text);
//       await user.updatePhotoURL(imageUrl);
//       await user.updatePhoneNumber(_phoneController.text);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Profile updated successfully")),
//       );

//       // Navigate to another screen or main app screen
//       Navigator.of(context).pop();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Setup Profile"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: "Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _phoneController,
//               decoration: const InputDecoration(
//                 labelText: "Phone Number",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _image != null
//                 ? Image.file(_image!)
//                 : IconButton(
//                     icon: const Icon(Icons.add_a_photo),
//                     onPressed: _pickImage,
//                   ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _saveProfile,
//               child: const Text("Save Profile"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
