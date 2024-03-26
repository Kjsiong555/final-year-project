// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/pages/record_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:final_year_project/pages/top_card.dart';

import '../logic/FirebaseController.dart';

class InputPage extends StatefulWidget {
  InputPage();
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  String? _selectedCategory;
  String? _selectedType;
  DateTime? _selectedDate;
  TextEditingController _amountController = TextEditingController();
  TextEditingController _detailController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseController firebaseController = Get.find<FirebaseController>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future getUserBankBalance(String? uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('user_bank').doc(uid).get();

    if (snapshot.exists) {
      return snapshot.data()?['balance'];
    }

    return null; // Return null if the document does not exist
  }

  Future<void> insertDatabase(String type, String category, String date,
      String amount, String detail) async {
    String? uid = user?.uid;
    CollectionReference transactions =
        FirebaseFirestore.instance.collection('transaction');

    DocumentReference newTransaction = await transactions.add({
      'uid': uid,
      'type': type,
      'category': category,
      'date': date,
      'amount': amount,
      'detail': detail,
      'documentId': '',
    });

    String documentId = newTransaction.id;
    await newTransaction.update({'documentId': documentId});
    // Update the document with the generated document ID
    DocumentSnapshot snapshot = await newTransaction.get();
    Map<String, dynamic> newData = snapshot.data() as Map<String, dynamic>;
    firebaseController.addItemToDataList(newData);
    firebaseController.itemForBudget = newData;
    firebaseController.updateBudgetWithTransaction();
    // The code below is for when the user insert income or expense the code will update the balance in the user bank
    int intAmount = int.parse(amount);
    if (type == 'Income') {
      // Add the amount to the user's balance
      if (uid != null) {
        // Check if a document with the given UID exists
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user_bank')
            .doc(uid)
            .get();
        if (snapshot.exists) {
          // If the document exists, update the balance field
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            int currentBalance = data['balance'] ?? 0;
            int newBalance = currentBalance + intAmount;
            await FirebaseFirestore.instance
                .collection('user_bank')
                .doc(uid)
                .update({'balance': newBalance});
          }
        } else {
          // If the document doesn't exist, create a new document with the UID and balance
          await FirebaseFirestore.instance
              .collection('user_bank')
              .doc(uid)
              .set({
            'uid': uid,
            'balance': intAmount,
          });
        }
      }
      setState(() {});
    } else {
      // Subtract the amount from the user's balance
      if (uid != null) {
        // Check if a document with the given UID exists
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('user_bank')
            .doc(uid)
            .get();
        if (snapshot.exists) {
          // If the document exists, update the balance field
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

          if (data != null) {
            int currentBalance = data['balance'] ?? 0;
            int newBalance = currentBalance - intAmount;

            await FirebaseFirestore.instance
                .collection('user_bank')
                .doc(uid)
                .update({'balance': newBalance});
          }
          
          setState(() {});
        } else {
          // If the document doesn't exist, create a new document with the UID and balance
          await FirebaseFirestore.instance
              .collection('user_bank')
              .doc(uid)
              .set({
            'uid': uid,
            'balance': -intAmount, // Set balance as negative for the expense
          });
        }
      }
    }
  }

  String _getFormattedDate(DateTime? date) {
    if (date == null) return '';
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return formattedDate;
  }

// if user didn't fill all the fields pop up alert for user else just insert into database
  Future<void> _saveData() async {
    if (_selectedType == null ||
        _selectedCategory == null ||
        _amountController.text.isEmpty ||
        _selectedDate == null) {
      AlertDialog(
        title: Text('Warning'),
        content: Text('Please fill in the field.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    } else {
      // Insert data into the database
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Please Wait"),
              content: CircularProgressIndicator(),
            );
          },
        );

        await insertDatabase(
          _selectedType.toString(),
          _selectedCategory.toString(),
          _getFormattedDate(_selectedDate),
          _amountController.text,
          _detailController.text,
        );

        Navigator.pop(context); // Close the "Please Wait" dialog
        Navigator.pop(context); // Close the input page
        setState(() {});
      } catch (e) {
        // Handle errors
        print('Error: $e');
        Navigator.pop(context); // Close the "Please Wait" dialog
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
        titleSpacing: 3,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveData,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                      _selectedCategory = null; // Reset selected category
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'Income',
                      child: Text('Income'),
                    ),
                    DropdownMenuItem(
                      value: 'Expense',
                      child: Text('Expense'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Type',
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: _selectedType != null
                      ? (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        }
                      : null,
                  items: _selectedType == 'Income'
                      ? [
                          DropdownMenuItem(
                            value: 'salary',
                            child: Text('Salary'),
                          ),
                          DropdownMenuItem(
                            value: 'stock',
                            child: Text('Stock'),
                          ),
                          DropdownMenuItem(
                            value: 'side hustle',
                            child: Text('Side hustle'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ]
                      : [
                          DropdownMenuItem(
                            value: 'baby',
                            child: Text('Baby'),
                          ),
                          DropdownMenuItem(
                            value: 'car',
                            child: Text('Car'),
                          ),
                          DropdownMenuItem(
                            value: 'food',
                            child: Text('Food'),
                          ),
                          DropdownMenuItem(
                            value: 'shopping',
                            child: Text('Shopping'),
                          ),
                          DropdownMenuItem(
                            value: 'real estate',
                            child: Text('Real estate'),
                          ),
                          DropdownMenuItem(
                            value: 'insurance',
                            child: Text('Insurance'),
                          ),
                          DropdownMenuItem(
                            value: 'tax',
                            child: Text('Tax'),
                          ),
                          DropdownMenuItem(
                            value: 'bills',
                            child: Text('Bills'),
                          ),
                          DropdownMenuItem(
                            value: 'transportation',
                            child: Text('Transportation'),
                          ),
                          DropdownMenuItem(
                            value: 'entertainment',
                            child: Text('Entertainment'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                  decoration: InputDecoration(
                    labelText: 'Category',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _detailController,
                  decoration: InputDecoration(
                    labelText: 'Details',
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
