// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:hive/hive.dart';
// import '../../model/chatlist.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;

// class ProfileTab extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;
//   const ProfileTab(
//       {Key? key, required this.userModel, required this.firebaseUser})
//       : super(key: key);

//   @override
//   State<ProfileTab> createState() => _ProfileTabState();
// }

// class _ProfileTabState extends State<ProfileTab> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();

//   User? _user;
//   String? _fullName;
//   String? _phoneNumber;
//   String? _photoUrl;
//   Box? _imageBox;

//   bool _isLoading = false; // Flag to track loading state

//   @override
//   void initState() {
//     super.initState();
//     _user = _auth.currentUser;
//     _initHive();
//     if (_user != null) {
//       _fetchUserData();
//     }
//     _auth.authStateChanges().listen((user) {
//       setState(() {
//         _user = user;
//         if (_user != null) {
//           _fetchUserData();
//         }
//       });
//     });
//   }

//   Future<void> _initHive() async {
//     final appDocumentDir =
//         await path_provider.getApplicationDocumentsDirectory();
//     Hive.init(appDocumentDir.path);
//     _imageBox = await Hive.openBox('images');
//   }

//   Future<void> _fetchUserData() async {
//     setState(() {
//       _isLoading = true; // Set loading state to true
//     });
//     if (_user != null) {
//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(_user!.uid).get();
//       if (userDoc.exists) {
//         setState(() {
//           _fullName = userDoc.get('name');
//           _phoneNumber = userDoc.get('phone');
//           _photoUrl = userDoc.get('profileImageUrl');
//           _loadImageLocally();
//         });
//         // Store data in Hive
//         var userBox = Hive.box('user_data');
//         userBox.put('fullName', _fullName);
//         userBox.put('phoneNumber', _phoneNumber);
//         userBox.put('photoUrl', _photoUrl);
//       } else {
//         setState(() {
//           _fullName = 'No name';
//           _phoneNumber = 'No phone number';
//           _photoUrl = null;
//         });
//       }
//     }
//     setState(() {
//       _isLoading =
//           false; // Set loading state to false after data fetch completes
//     });
//   }

//   Future<void> _loadImageLocally() async {
//     if (_photoUrl != null) {
//       final imageData = await _imageBox?.get(_user!.uid);
//       if (imageData != null) {
//         setState(() {
//           _photoUrl = imageData;
//         });
//       } else {
//         await _downloadAndStoreImage();
//       }
//     }
//   }

//   Future<void> _pickAndUploadImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         File imageFile = File(pickedFile.path);
//         String downloadUrl = await _uploadImage(imageFile);
//         await _firestore.collection('users').doc(_user!.uid).update({
//           'profileImageUrl': downloadUrl,
//         });
//         _imageBox?.put(_user!.uid, downloadUrl);
//         setState(() {
//           _photoUrl = downloadUrl;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   Future<String> _uploadImage(File image) async {
//     Reference storageReference = _storage.ref().child(
//         'profile_images/${_user!.uid}/${DateTime.now().millisecondsSinceEpoch}');
//     UploadTask uploadTask = storageReference.putFile(image);
//     await uploadTask.whenComplete(() => null);
//     return await storageReference.getDownloadURL();
//   }

//   Future<void> _downloadAndStoreImage() async {
//     final imageUrl = await _storage.refFromURL(_photoUrl!).getDownloadURL();
//     _imageBox?.put(_user!.uid, imageUrl);
//     setState(() {
//       _photoUrl = imageUrl;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 16),
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: _photoUrl != null
//                         ? NetworkImage(_photoUrl!)
//                         : null, // If _photoUrl is null, set backgroundImage to null
//                     child: _photoUrl == null
//                         ? const Icon(Icons.add_a_photo, size: 50)
//                         : null,
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       height: 25,
//                       width: 25,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: IconButton(
//                         iconSize: 11,
//                         icon: const Icon(Icons.mode_edit_outline_outlined),
//                         onPressed: _pickAndUploadImage,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               _isLoading
//                   ? const CircularProgressIndicator() // Show loading indicator while fetching data
//                   : Column(
//                       children: [
//                         Text(
//                           _fullName ?? 'Loading...',
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _user?.email ?? 'No email',
//                           style:
//                               const TextStyle(fontSize: 16, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 16),
//                         ListTile(
//                           leading: const Icon(Icons.phone),
//                           title: Text(
//                             _phoneNumber ?? 'No phone number',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () async {
//                   await _auth.signOut();
//                   setState(() {
//                     _user = null;
//                     _fullName = null;
//                     _phoneNumber = null;
//                     _photoUrl = null;
//                   });
//                 },
//                 child: const Text("Log Out"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:hive/hive.dart';
// import '../../model/chatlist.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;

// class ProfileTab extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;
//   const ProfileTab(
//       {Key? key, required this.userModel, required this.firebaseUser})
//       : super(key: key);

//   @override
//   State<ProfileTab> createState() => _ProfileTabState();
// }

// class _ProfileTabState extends State<ProfileTab> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final ImagePicker _picker = ImagePicker();

//   User? _user;
//   String? _photoUrl;
//   Box? _imageBox;

//   bool _isLoading = false; // Flag to track loading state

//   @override
//   void initState() {
//     super.initState();
//     _user = _auth.currentUser;
//     _initHive();
//     if (_user != null) {
//       _fetchUserData();
//     }
//     _auth.authStateChanges().listen((user) {
//       setState(() {
//         _user = user;
//         if (_user != null) {
//           _fetchUserData();
//         }
//       });
//     });
//   }

//   Future<void> _initHive() async {
//     final appDocumentDir =
//         await path_provider.getApplicationDocumentsDirectory();
//     Hive.init(appDocumentDir.path);
//     _imageBox = await Hive.openBox('images');
//   }

//   Future<void> _fetchUserData() async {
//     setState(() {
//       _isLoading = true; // Set loading state to true
//     });
//     if (_user != null) {
//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(_user!.uid).get();
//       if (userDoc.exists) {
//         setState(() {
//           _photoUrl = userDoc.get('profileImageUrl');
//           _loadImageLocally();
//         });
//         // Store data in Hive
//         var userBox = Hive.box('user_data');
//         userBox.put('photoUrl', _photoUrl);
//       } else {
//         setState(() {
//           _photoUrl = null;
//         });
//       }
//     }
//     setState(() {
//       _isLoading =
//           false; // Set loading state to false after data fetch completes
//     });
//   }

//   Future<void> _loadImageLocally() async {
//     if (_photoUrl != null) {
//       final imageData = await _imageBox?.get(_user!.uid);
//       if (imageData != null) {
//         setState(() {
//           _photoUrl = imageData;
//         });
//       } else {
//         await _downloadAndStoreImage();
//       }
//     }
//   }

//   Future<void> _pickAndUploadImage() async {
//     try {
//       final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         File imageFile = File(pickedFile.path);
//         String downloadUrl = await _uploadImage(imageFile);
//         await _firestore.collection('users').doc(_user!.uid).update({
//           'profileImageUrl': downloadUrl,
//         });
//         _imageBox?.put(_user!.uid, downloadUrl);
//         setState(() {
//           _photoUrl = downloadUrl;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }
//   }

//   Future<String> _uploadImage(File image) async {
//     Reference storageReference = _storage.ref().child(
//         'profile_images/${_user!.uid}/${DateTime.now().millisecondsSinceEpoch}');
//     UploadTask uploadTask = storageReference.putFile(image);
//     await uploadTask.whenComplete(() => null);
//     return await storageReference.getDownloadURL();
//   }

//   Future<void> _downloadAndStoreImage() async {
//     final imageUrl = await _storage.refFromURL(_photoUrl!).getDownloadURL();
//     _imageBox?.put(_user!.uid, imageUrl);
//     setState(() {
//       _photoUrl = imageUrl;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 16),
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage: _photoUrl != null
//                         ? NetworkImage(_photoUrl!)
//                         : null, // If _photoUrl is null, set backgroundImage to null
//                     child: _photoUrl == null
//                         ? const Icon(Icons.add_a_photo, size: 50)
//                         : null,
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       height: 25,
//                       width: 25,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: IconButton(
//                         iconSize: 11,
//                         icon: const Icon(Icons.mode_edit_outline_outlined),
//                         onPressed: _pickAndUploadImage,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               _isLoading
//                   ? const CircularProgressIndicator() // Show loading indicator while fetching data
//                   : Column(
//                       children: [
//                         Text(
//                           widget.userModel.name ?? 'Loading...',
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           widget.firebaseUser.email ?? 'No email',
//                           style:
//                               const TextStyle(fontSize: 16, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 16),
//                         // ListTile(
//                         //   leading: const Icon(Icons.phone),
//                         //   title: Text(
//                         //     widget.userModel. ?? 'No phone number',
//                         //     style: const TextStyle(fontSize: 16),
//                         //   ),
//                         // ),
//                       ],
//                     ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () async {
//                   await _auth.signOut();
//                   setState(() {
//                     _user = null;
//                     _photoUrl = null;
//                   });
//                 },
//                 child: const Text("Log Out"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:chat_app/Screens/authentication/SignUpScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import '../../model/chatlist.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ProfileTab extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const ProfileTab(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  String? _photoUrl;
  Box? _imageBox;

  bool _isLoading = false; // Flag to track loading state

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
    setState(() {
      _isLoading = true; // Set loading state to true
    });
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _photoUrl = userDoc.get('profileImageUrl');
          _loadImageLocally();
        });
        // Store data in Hive
        var userBox = Hive.box('user_data');
        userBox.put('photoUrl', _photoUrl);
      } else {
        setState(() {
          _photoUrl = null;
        });
      }
    }
    setState(() {
      _isLoading =
          false; // Set loading state to false after data fetch completes
    });
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

  Future<void> _logout() async {
    await _auth.signOut();
    await Hive.box('user_data').clear(); // Clear Hive storage
    setState(() {
      _user = null;
      _photoUrl = null;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _photoUrl != null
                        ? NetworkImage(_photoUrl!)
                        : null, // If _photoUrl is null, set backgroundImage to null
                    child: _photoUrl == null
                        ? const Icon(Icons.add_a_photo, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        iconSize: 11,
                        icon: const Icon(Icons.mode_edit_outline_outlined),
                        onPressed: _pickAndUploadImage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator() // Show loading indicator while fetching data
                  : Column(
                      children: [
                        Text(
                          widget.userModel.name ?? 'Loading...',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.firebaseUser.email ?? 'No email',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                child: const Text("Log Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
