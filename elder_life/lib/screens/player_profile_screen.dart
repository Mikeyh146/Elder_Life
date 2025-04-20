import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up with Email
  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Fluttertoast.showToast(msg: 'Account created successfully!');
      print("User created: ${userCredential.user?.email}");
      // Redirect to another screen or display user data
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Something went wrong.';
      Fluttertoast.showToast(msg: message);
    }
  }

  // Login with Email
  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Fluttertoast.showToast(msg: 'Login successful!');
      print("User logged in: ${userCredential.user?.email}");
      // Redirect to another screen or show logged-in user details
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'Something went wrong.';
      Fluttertoast.showToast(msg: message);
    }
  }

  // Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      Fluttertoast.showToast(msg: 'Google Sign-In successful!');
      print("User logged in: ${userCredential.user?.email}");
      // Redirect to another screen or show logged-in user details
    } catch (e) {
      Fluttertoast.showToast(msg: 'Google Sign-In failed!');
      print('Google Sign-In Error: $e');
    }
  }

  // Log out
  Future<void> _logOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Fluttertoast.showToast(msg: 'Logged out successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Player Profile")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Login / Sign Up",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text("Login with Email"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text("Sign Up with Email"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithGoogle,
                child: const Text("Login with Google"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logOut,
                child: const Text("Log Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
