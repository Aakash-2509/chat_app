import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isLogin = false; // to toggle between sign-up and login forms

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
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
    return const BottomNavigation();
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
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
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
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
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

      // Store basic user details in Firestore
      await _firestore.collection('users').doc(_user!.uid).set({
        'uid': _user!.uid,
        'email': _user!.email,
      });

      setState(() {
        _user = userCredential.user;
      });

      // Navigate to the profile setup screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProfileSetupScreen(user: _user!),
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
      setState(() {
        _user = userCredential.user;
      });
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
        await _firestore.collection('users').doc(_user!.uid).set({
          'uid': _user!.uid,
          'email': _user!.email,
        });
      }

      setState(() {
        _user = userCredential.user;
      });

      // Navigate to the profile setup screen if the user is new
      if (userCredential.additionalUserInfo!.isNewUser) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(user: _user!),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavigation()),
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
