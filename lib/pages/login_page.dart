// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_new

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Google login
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text controller
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Reminder'),
                content:
                    Text('Please enter both email and password Correctly.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    }
  }

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Google login method
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the authentication details from the Google user
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential with the obtained authentication details
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the created credential

      return await _auth.signInWithCredential(credential);

      // Return the UserCredential
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  Icons.heart_broken,
                  size: 100,
                  color: Colors.pinkAccent[100],
                ),

                //Hello again!
                Text("Hello again!",
                    style: GoogleFonts.fasthand(
                      fontSize: 50,
                    )),
                SizedBox(height: 20),
                Text(
                  "Welcome back, you've been missed!",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                // email textfield
                SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16),
                      border: InputBorder.none,
                      hintText: "Email",
                      fillColor: Colors.deepPurpleAccent,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 170, 170, 170)),
                    ),
                  ),
                ),

                // password textfield
                SizedBox(height: 12),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                  child: TextField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16),
                      border: InputBorder.none,
                      hintText: "Password",
                      fillColor: Colors.deepPurpleAccent,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 170, 170, 170)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                // forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ForgotPasswordPage();
                        }));
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ]),
                ),

                // sign in button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: signIn,
                          splashColor: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              "Sign in",
                              style: TextStyle(
                                color: Color.fromARGB(255, 206, 204, 201),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Other login method

                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Divider(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Other login method',
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                    Flexible(
                      flex: 2,
                      child: Divider(
                        height: 1,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // login with google
                InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () async {
                    await _signInWithGoogle();
                  },
                  splashColor: Colors.transparent, // Customize the splash color
                  highlightColor: Colors.grey
                      .withOpacity(0.3), // Customize the highlight color
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo_google.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
                //register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not a member? "),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(
                        "Register now!",
                        style: TextStyle(
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
