// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/pages/user_input_expense.dart';

class TopCard extends StatefulWidget {
  TopCard();
  @override
  State<TopCard> createState() => _TopCardState();
}

class _TopCardState extends State<TopCard> {
  late int balance = 0;
  // Create a StreamSubscription to listen for changes to the Firebase balance data
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      balanceSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Start listening for changes to the Firebase balance data
    balanceSubscription = FirebaseFirestore.instance
        .collection('user_bank')
        .doc(getUidOfCurrentUser())
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        int newBalance = snapshot.data()?['balance'] ?? 0;
        setState(() {
          balance = newBalance;
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed to avoid memory leaks
    balanceSubscription.cancel();
    super.dispose();
  }

  String? getUidOfCurrentUser() {
    // Get the current authenticated user
    final User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is authenticated
    if (user != null) {
      // Access the UID of the user
      String uid = user.uid;
      return uid;
    }
    return null;
  }

  Future<void> Insertbank(int balance) async {
    String? uid = getUidOfCurrentUser();

    if (uid != null) {
      // Check if a document with the given UID exists
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_bank')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        // If the document exists, update the balance field
        await FirebaseFirestore.instance
            .collection('user_bank')
            .doc(uid)
            .update({'balance': balance});
      } else {
        // If the document doesn't exist, create a new document with the UID and balance
        await FirebaseFirestore.instance.collection('user_bank').doc(uid).set({
          'uid': uid,
          'balance': balance,
        });
      }
      setState(() {});
    }
  }

  void _showBalanceInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Balance'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                balance = int.tryParse(value)!;
              });
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: 'Enter balance'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Insertbank(balance);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> getUserBankBalance(String? uid) async {
    if (uid == null) return null;

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('user_bank')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        int? balance = snapshot.data()?['balance'] ?? 0;
        return balance;
      }

      return null; // Return null if the document does not exist
    } catch (e) {
      print('Error while fetching user bank balance: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            height: 200,
            color: Colors.grey[200],
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                  Text(
                    "B A L A N C E",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                  FutureBuilder<int?>(
                    future: getUserBankBalance(getUidOfCurrentUser()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show a loading indicator while fetching the balance
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: Unable to fetch balance'); // Show an error message if something goes wrong
                      } else {
                        int? balance = snapshot.data;
                        return Text(
                          '${balance ?? 0}', // Use the balance once it's available, or use a default value (0) if null
                          style:
                              TextStyle(color: Colors.grey[800], fontSize: 48),
                        );
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[
                              200], // Use backgroundColor instead of primary
                        ),
                        onPressed: _showBalanceInputDialog,
                        child: Text('Set Balance'),
                      ),
                    ],
                  ),
                ]))));
  }
}
