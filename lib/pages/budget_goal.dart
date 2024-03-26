// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/logic/FirebaseController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BudgetAndGoalPage extends StatefulWidget {
  @override
  _BudgetAndGoalPageState createState() => _BudgetAndGoalPageState();
}

class _BudgetAndGoalPageState extends State<BudgetAndGoalPage> {
  String? _selectedCategory;
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseController firebaseController = Get.find<FirebaseController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Budgets and Goals'),
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          _buildCard(
            title: 'Add Budget',
            onTap: _showBudgetInput,
          ),
          _buildCard(
            title: 'Add Goal',
            onTap: _showGoalInput,
          ),
          SizedBox(height: 16), // Add spacing
          Text(
            "Budget List",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('budget').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator(); // Display a loading indicator while data is loading.
                }

                // Assuming you have multiple budget documents, you can access them here
                var budgetDocuments = snapshot.data!.docs;

                // Get the current date
                DateTime currentDate = DateTime.now();

                return ListView.builder(
                  itemCount: budgetDocuments.length,
                  itemBuilder: (context, index) {
                    var budgetData = budgetDocuments[index].data();
                    DateTime? budgetDate; // Declare budgetDate as nullable

                    if (budgetData['date'] != null) {
                      // Initialize budgetDate only if 'date' is not null
                      budgetDate = budgetData['date'].toDate();
                    } else {
                      // Skip displaying this budget item if 'date' is null
                      return null;
                    }

                    // Check if budgetDate is after the current date
                    if (currentDate.isAfter(budgetDate!)) {
                      // Budget is overdue, don't show it
                      return SizedBox.shrink();
                    }

                    return ListTile(
                      title: Text(
                        'Name: ${budgetData['name']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category: ${budgetData['category']}',
                            style: TextStyle(
                                fontSize: 16, fontFamily: 'YourCustomFont'),
                          ),
                          Text(
                            'Current Amount: \$${budgetData['current_amount']}',
                            style: TextStyle(
                                fontSize: 16, fontFamily: 'YourCustomFont'),
                          ),
                          Text(
                            'Target Amount: \$${budgetData['amount']}',
                            style: TextStyle(
                                fontSize: 16, fontFamily: 'YourCustomFont'),
                          ),
                          Text(
                            'Target Date: ${DateFormat('yyyy-MM-dd').format(budgetDate)}',
                            style: TextStyle(
                                fontSize: 16, fontFamily: 'YourCustomFont'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Goal interface
          SizedBox(height: 16), // Add spacing
          Text(
            "Goal List",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('goal').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator(); // Display a loading indicator while data is loading.
                }

                // Assuming you have multiple goal documents, you can access them here
                var goalDocuments = snapshot.data!.docs;

                // Get the current date
                DateTime currentDate = DateTime.now();

                return ListView.builder(
                  itemCount: goalDocuments.length,
                  itemBuilder: (context, index) {
                    var goalData = goalDocuments[index].data();
                    DateTime goalDate = goalData['date'].toDate();
                    bool isFinished = goalData['finished'] ?? false;

                    // Check if the goal is finished, and if it is, don't show it
                    if (isFinished) {
                      return SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        // Show a bottom sheet or popup menu when the ListTile is tapped
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.attach_money),
                                  title: Text('Add Saved Amount'),
                                  onTap: () {
                                    // save the amount to firebase
                                    addSavedAmount(context,
                                        goalDocuments[index], user!.uid);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.check),
                                  title: Text('Set Goal as Finished'),
                                  onTap: () {
                                    //  when clicked change this data to finished
                                    final item = goalDocuments[index];
                                    DocumentReference documentReference =
                                        FirebaseFirestore.instance
                                            .collection('goal')
                                            .doc(item["documentId"]);

                                    Map<String, dynamic> updates = {
                                      'finished': true,
                                    };
                                    documentReference.update(updates).then((_) {
                                      print('Document updated successfully');
                                    }).catchError((error) {
                                      print('Error updating document: $error');
                                    });
                                    Navigator.pop(
                                        context); // Close the bottom sheet
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: ListTile(
                        title: Text(
                          'Name: ${goalData['name']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Amount: \$${goalData['current_amount']}',
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'YourCustomFont'),
                            ),
                            Text(
                              'Target Amount: \$${goalData['amount']}',
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'YourCustomFont'),
                            ),
                            Text(
                              'Detail: ${goalData['detail']}',
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'YourCustomFont'),
                            ),
                            Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(goalDate)}',
                              style: TextStyle(
                                  fontSize: 16, fontFamily: 'YourCustomFont'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ])));
  }

  void addSavedAmount(
      BuildContext context, DocumentSnapshot goalDocument, String userId) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Saved Amount"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Amount"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                amountController.dispose(); // Dispose of the controller
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Get the input amount as a double
                double inputAmount =
                    double.tryParse(amountController.text) ?? 0.0;

                // Convert the double input to an integer
                int intAmount = inputAmount.toInt();

                // Update the 'current_amount' field in the goal document as a double
                await goalDocument.reference.update({
                  'current_amount': FieldValue.increment(inputAmount),
                });

                // Deduct the input amount from the user's bank balance as an integer
                await FirebaseFirestore.instance
                    .collection('user_bank')
                    .doc(user!.uid)
                    .update({
                  'balance': FieldValue.increment(-intAmount),
                });

                Navigator.of(context).pop(); // Close the dialog
                setState(() {});
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showBudgetInput() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String budgetName = '';
        double budgetAmount = 0.0;
        DateTime selectedDate = DateTime.now();
        String? userId = user?.uid;

        return AlertDialog(
          title: Text("Add Budget"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  onChanged: (value) {
                    budgetName = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  items: [
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
                TextField(
                  decoration: InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    budgetAmount = double.tryParse(value) ?? 0.0;
                  },
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text("Date: "),
                    TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Check for null values and handle accordingly
                if (userId != null &&
                    budgetName != null &&
                    _selectedCategory != null) {
                  // Handle adding the budget with the specified details here
                  // You can save it to your data model or database
                  _addBudgetToFirestore(userId, budgetName, _selectedCategory!,
                      budgetAmount, selectedDate);
                  Navigator.of(context).pop();
                } else {
                  // Handle the case where there are null values (e.g., show an error message)
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addBudgetToFirestore(
    String userId, // Pass the user's ID as a parameter
    String name,
    String? category,
    double amount,
    DateTime date,
  ) {
    // Add one more day to the date
    DateTime newDate = date.add(Duration(days: 1));

    FirebaseFirestore.instance.collection('budget').add({
      'uid': userId, // Add the user's ID to the budget document
      'name': name,
      'category': category,
      'amount': amount,
      'date': newDate, // Use the updated date
      'current_amount': 0,
    }).then((value) {
      // Print the document ID
      print("Budget added with ID: ${value.id}");
      // Update the document with the generated ID
      value.update({'documentId': value.id});
    }).catchError((error) {
      print("Error adding budget: $error");
    });
  }

  void _showGoalInput() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String goalName = '';
        double goalAmount = 0.0;
        DateTime selectedDate = DateTime.now();
        String? userId = user?.uid;
        String goalDetail = '';

        String? nameError;
        String? amountError;

        return AlertDialog(
          title: Text("Add Goal"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration:
                      InputDecoration(labelText: "Name", errorText: nameError),
                  onChanged: (value) {
                    goalName = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Amount", errorText: amountError),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Validate the amount
                    if (double.tryParse(value) == null) {
                      amountError = "Invalid amount";
                    } else {
                      amountError =
                          null; // Clear the error if the input is valid
                      goalAmount = double.parse(value);
                    }
                    setState(() {});
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Detail"),
                  onChanged: (value) {
                    goalDetail = value;
                  },
                ),
                Row(
                  children: [
                    Text("Date: "),
                    TextButton(
                      onPressed: () async {
                        final DateTime pickedDate = (await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        ))!;
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate the input fields
                if (goalName.isEmpty) {
                  nameError = "Name cannot be blank";
                } else {
                  nameError = null;
                }

                if (goalAmount <= 0) {
                  amountError = "Amount must be greater than 0";
                } else {
                  amountError = null;
                }

                if (nameError == null && amountError == null) {
                  // Save to database and close the dialog
                  _addGoalToFirebase(
                      goalName, goalAmount, selectedDate, goalDetail, userId);
                  Navigator.of(context).pop();
                } else {
                  setState(() {});
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addGoalToFirebase(goalName, goalAmount, goalDate, goalDetail, userId) {
    DateTime newDate = goalDate.add(Duration(days: 1));

    FirebaseFirestore.instance.collection('goal').add({
      'uid': userId, // Add the user's ID to the budget document
      'name': goalName,
      'amount': goalAmount,
      'date': newDate, // Use the updated date
      'detail': goalDetail,
      'finished': false,
      'current_amount': 0,
    }).then((value) {
      // Print the document ID
      print("Budget added with ID: ${value.id}");
      // Update the document with the generated ID
      value.update({'documentId': value.id});
    }).catchError((error) {
      print("Error adding budget: $error");
    });
  }

  Widget _buildCard({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(title),
          leading: Icon(Icons.add),
        ),
      ),
    );
  }
}
