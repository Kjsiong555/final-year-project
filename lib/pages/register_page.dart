// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _finalconfirmpasswordController = new TextEditingController();
  final _firstNameController = new TextEditingController();
  final _lastNameController = new TextEditingController();
  final _ageController = new TextEditingController();

  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _finalconfirmpasswordController.dispose();
    _ageController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if (passwordConfirm()) {
      try {
        // Check if email already exists
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential != null) {
          // User created successfully, add user details
          addUserDetails(
            _firstNameController.text.trim(),
            _lastNameController.text.trim(),
            int.parse(_ageController.text.trim()),
            _emailController.text.trim(),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // Email is already in use, show a warning message to the user
          showDialog(
            context:
                context, // You'll need to replace this with the correct context
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Email Already in Use'),
                content: Text('The provided email is already registered.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else if (e.code == 'weak-password') {
          // warn user if the password is too short
          showDialog(
            context:
                context, // You'll need to replace this with the correct context
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Password too weak'),
                content: Text('${e}'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Handle other FirebaseAuthException errors
          print('Error: ${e.code}');
        }
      }
    } else {
      showDialog(
        context:
            context, // You'll need to replace this with the correct context
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Wrong password'),
            content: Text('Please make sure the password is the same.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future addUserDetails(
      String firstName, String lastName, int age, String email) async {
    await FirebaseFirestore.instance.collection('users').add({
      'first name': firstName,
      'last name': lastName,
      'age': age,
      'email': email,
    });
  }

  bool passwordConfirm() {
    if (_passwordController.text.trim() ==
        _finalconfirmpasswordController.text.trim()) {
      return true;
    } else {
      return false;
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
                //Hello again!
                Text("Hello there!",
                    style: GoogleFonts.fasthand(
                      fontSize: 50,
                    )),
                SizedBox(height: 20),
                Text(
                  "Register below with your detail.",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),

                // first name
                SizedBox(height: 3),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16),
                      border: InputBorder.none,
                      hintText: "First name",
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                // last name
                SizedBox(height: 3),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16),
                      border: InputBorder.none,
                      hintText: "Last name",
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                // Age
                SizedBox(height: 3),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                  child: TextField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16),
                      border: InputBorder.none,
                      hintText: "Age",
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                // Email
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16),
                      border: InputBorder.none,
                      hintText: "Email",
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),

                // password textfield
                SizedBox(height: 3),
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
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 2),
                  child: TextField(
                    obscureText: true,
                    controller: _finalconfirmpasswordController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 16),
                      border: InputBorder.none,
                      hintText: "Confirm Password",
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
                // sign up button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: signUp,
                          splashColor: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                color: Color.fromARGB(255, 218, 144, 94),
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

                //register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("I am a member? "),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        "Login now!",
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
