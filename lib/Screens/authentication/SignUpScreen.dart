

import 'dart:developer';

import 'package:chat_app/model/chatlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';
import '../chatlist/BottomNavigation.dart';
import 'ProfileSetupScreen.dart'; // Import the new screen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLogin = false;
  bool _passwordVisible =
      false; // to toggle password visibility// to toggle between sign-up and login forms

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestNotificationPermissions();
    configureFirebaseMessaging();
    _auth.authStateChanges().listen((event) async {
      if (event != null) {
        _user = event;
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(_user!.uid).get();
        UserModel userModel =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNavigation(
              userModel: userModel,
              firebaseUser: _user!,
            ),
          ),
        );
      } else {
        setState(() {
          _user = event;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _user != null
          ? _userInfo()
          : (_isLogin ? _loginForm() : _signUpForm()),
    );
  }

  Widget _userInfo() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(_user!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error loading user data"));
        } else if (snapshot.hasData && snapshot.data != null) {
          UserModel userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          return BottomNavigation(
            userModel: userModel,
            firebaseUser: _user!,
          );



        } else {
          return const Center(child: Text("User not found"));
        }
      },
    );
  }

  Widget _signUpForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          

          TextField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleEmailSignUp,
            child: const Text("Sign Up with Email"),
          ),
          const SizedBox(height: 16),
          SignInButton(
            Buttons.google,
            text: "Sign up with Google",
            onPressed: _handleGoogleSignIn,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = true;
              });
            },
            child: const Text("Already have an account? Log in"),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          

          TextField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            decoration: InputDecoration(
              labelText: "Password",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleEmailLogin,
            child: const Text("Log in with Email"),
          ),
          const SizedBox(height: 16),
          SignInButton(
            Buttons.google,
            text: "Log in with Google",
            onPressed: _handleGoogleSignIn,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = false;
              });
            },
            child: const Text("Don't have an account? Sign up"),
          ),
        ],
      ),
    );
  }

  void _handleEmailSignUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _user = userCredential.user;

      String uid = userCredential.user!.uid;
      UserModel newuser = UserModel(
          uid: uid, email: _user!.email!, name: "", profileImageUrl: "");

      // Store basic user details in Firestore
      await _firestore.collection('users').doc(uid).set(newuser.toMap());

      // Navigate to the profile setup screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProfileSetupScreen(
            userModel: newuser,
            firebaseUser: _user!,
            user: _user!,
          ),
        ),
      );
    } catch (e) {
      log("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _handleEmailLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _user = userCredential.user;
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(_user!.uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BottomNavigation(
            userModel: userModel,
            firebaseUser: _user!,
          ),
        ),
      );
    } catch (e) {
      log("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _handleGoogleSignIn() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential userCredential =
          await _auth.signInWithProvider(googleProvider);
      _user = userCredential.user;

      // Store user details in Firestore if it's a new user
      if (userCredential.additionalUserInfo!.isNewUser) {
        UserModel newuser = UserModel(
            uid: _user!.uid,
            email: _user!.email!,
            name: "",
            profileImageUrl: "");
        await _firestore
            .collection('users')
            .doc(_user!.uid)
            .set(newuser.toMap());

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(
              userModel: newuser,
              firebaseUser: _user!,
              user: _user!,
            ),
          ),
        );
      } else {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(_user!.uid).get();
        UserModel userModel =
            UserModel.fromMap(userData.data() as Map<String, dynamic>);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNavigation(
              userModel: userModel,
              firebaseUser: _user!,
            ),
          ),
        );
      }
    } catch (e) {
      log("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
