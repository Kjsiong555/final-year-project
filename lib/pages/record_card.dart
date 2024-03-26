// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../logic/FirebaseController.dart';

class Record_card extends StatefulWidget {
  final void Function(int)? updateBalanceCallback;

  const Record_card({
    super.key,
    this.updateBalanceCallback,
  });
  @override
  State<Record_card> createState() => _Record_cardState();
}

class _Record_cardState extends State<Record_card> {
  final FirebaseController firebaseController = Get.find();
  late String currentUserUID;
  late String selectedDateRange;
  late DateTime startDate;
  late DateTime endDate;

  Map<String, String> categoryImages = {
    'salary': 'assets/images/salary.png',
    'stock': 'assets/images/stock.jpg',
    'side hustle': 'assets/images/side hustle.png',
    'other': 'assets/images/other.png',
    'baby': 'assets/images/baby.png',
    'car': 'assets/images/car.png',
    'food': 'assets/images/food.png',
    'shopping': 'assets/images/shopping.png',
    'real estate': 'assets/images/real estate.png',
    'insurance': 'assets/images/insurance.jpg',
    'tax': 'assets/images/tax.png',
    'bills': 'assets/images/bills.png',
    'transportation': 'assets/images/transportation.png',
    'entertainment': 'assets/images/entertainment.png',
  };

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    selectedDateRange = 'Today';
    setSelectedDateRange(selectedDateRange);
    firebaseController.fetchDataFromFirebase(
        currentUserUID, startDate, endDate);
    firebaseController.setDateRangeFromSelection(selectedDateRange);
  }

  void setSelectedDateRange(String dateRange) {
    setState(() {
      selectedDateRange = dateRange;
    });

    DateTime now = DateTime.now();
    if (selectedDateRange == 'Today') {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (selectedDateRange == 'This week') {
      int dayOfWeek = now.weekday;
      startDate = now.subtract(Duration(days: dayOfWeek - 1));
      endDate =
          startDate.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    } else if (selectedDateRange == 'This month') {
      startDate = DateTime(now.year, now.month);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else if (selectedDateRange == 'This year') {
      startDate = DateTime(now.year);
      endDate = DateTime(now.year + 1, 12, 0, 23, 59, 59);
    }
  }

  Future<void> getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserUID = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.grey[200],
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text('Last Record'),
                subtitle: Text(selectedDateRange),
                trailing: InkWell(
                  onTap: _showPopupDialog,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.more_vert),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Obx(() => ListView.builder(
                      shrinkWrap: true, // Important
                      physics: NeverScrollableScrollPhysics(), // Important
                      itemCount: firebaseController.dataList.length,
                      itemBuilder: (context, index) {
                        final item = firebaseController.dataList[index];
                        return GestureDetector(
                          onTap: () {
                            _showEditDeleteOptions(item);
                          },
                          child: Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      categoryImages[item["category"]] ??
                                          'assets/images/default.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text("${item["category"]}"),
                                  ],
                                ),
                              ),
                              subtitle: Text(item["type"]),
                              trailing: Text(
                                NumberFormat.currency(
                                        locale: 'en_US', symbol: '\$')
                                    .format(double.parse(item["amount"])),
                                style: TextStyle(
                                  color: item["type"] == 'Income'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPopupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            child: Container(
              width: 300,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDateRange,
                      onChanged: (value) {
                        setSelectedDateRange(value!);
                        firebaseController.fetchDataFromFirebase(
                            currentUserUID, startDate, endDate);
                        firebaseController
                            .setDateRangeFromSelection(selectedDateRange);
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'Today',
                          child: Text('Today'),
                        ),
                        DropdownMenuItem(
                          value: 'This week',
                          child: Text('This week'),
                        ),
                        DropdownMenuItem(
                          value: 'This month',
                          child: Text('This month'),
                        ),
                        DropdownMenuItem(
                          value: 'This year',
                          child: Text('This year'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Review mode',
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {});
                          },
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {});
                          },
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDeleteOptions(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _editRecord(item);
                },
                title: Text('Edit'),
                leading: Icon(Icons.edit),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  deleteRecord(item);
                },
                title: Text('Delete'),
                leading: Icon(Icons.delete),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                "Detail text: \n ${item['detail']}",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        );
      },
    );
  }

  void _editRecord(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String _selectedType = item['type'];
        String? _selectedCategory = item['category'];
        TextEditingController _amountController =
            TextEditingController(text: item['amount'].toString());
        TextEditingController _detailController =
            TextEditingController(text: item['detail'].toString());
        bool isLoading = false; // Add a loading indicator flag

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Record'),
              content: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                              // Reset selected category when type changes
                              _selectedCategory = null;
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
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
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
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                          ),
                        ),
                        TextField(
                          controller: _detailController,
                          decoration: InputDecoration(
                            labelText: 'Details',
                          ),
                        ),
                        TextButton(
                          onPressed: () => _selectDate(context, item),
                          child: Text(
                            'Selected Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(item['date']))}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading) // Show loading indicator when isLoading is true
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null // Disable the button when loading
                      : () async {
                          // Start loading
                          setState(() {
                            isLoading = true;
                          });

                          // Update the item with the edited values
                          // Calculate the difference in the amount
                          double oldAmount = double.parse(item['amount']);
                          double newAmount =
                              double.parse(_amountController.text);
                          double amountDifference = newAmount - oldAmount;

                          // Update the item with the edited values
                          item['type'] = _selectedType;
                          item['category'] = _selectedCategory;
                          item['amount'] = _amountController.text;
                          item['detail'] = _detailController.text;

                          // Update the record
                          updateRecord(item);

                          // Update the balance in the database
                          await updateBalance(
                              item['type'], amountDifference, item['category']);
                          // Update the budget

                          int index = firebaseController.dataList.indexWhere(
                              (element) =>
                                  element['documentId'] == item['documentId']);
                          if (index != -1) {
                            firebaseController.dataList[index] = item;
                            firebaseController.dataList
                                .refresh(); // Notify the UI of the change
                          }

                          // Stop loading
                          setState(() {
                            isLoading = false;
                          });

                          Navigator.pop(context);
                        },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to update the balance in the database
  Future<void> updateBalance(
      String type, double amountDifference, String category) async {
    String uid = currentUserUID;

    try {
      if (uid.isNotEmpty) {
        DocumentReference userBankRef =
            FirebaseFirestore.instance.collection('user_bank').doc(uid);

        // Fetch the document snapshot
        DocumentSnapshot userBankSnapshot = await userBankRef.get();

        if (userBankSnapshot.exists) {
          int currentBalance = userBankSnapshot.get('balance') ?? 0;

          if (type == 'Income') {
            currentBalance += amountDifference.toInt();
          } else if (type == 'Expense') {
            currentBalance -= amountDifference.toInt();
            await updateUserBankBalance(uid, currentBalance);
            await updateBudget(uid, category, amountDifference);
          }

          // Update the balance in Firestore
          DocumentReference docRef =
              FirebaseFirestore.instance.collection("user_bank").doc(uid);
          Map<String, dynamic> yourData = {
            // Replace with the data you want to update in the document
            'balance': currentBalance,
          };
          await docRef.update(yourData);
        } else {
          print('User balance document does not exist in Firestore.');
        }
      } else {
        print('User is not logged in or has no UID.');
      }
    } catch (e) {
      print('Error updating balance: $e');
    }
  }

  Future<void> updateBudget(
      String uid, String category, double amountDifference) async {
    // Fetch the budget document for the specified category
    QuerySnapshot budgetQuery = await FirebaseFirestore.instance
        .collection('budget')
        .where('uid', isEqualTo: uid)
        .where('category', isEqualTo: category)
        .get();

    if (budgetQuery.docs.isNotEmpty) {
      for (QueryDocumentSnapshot budgetDoc in budgetQuery.docs) {
        double currentAmount = budgetDoc.get('current_amount');
        double updatedAmount = currentAmount + amountDifference;

        // Update the budget amount for the specified category
        DocumentReference budgetRef =
            FirebaseFirestore.instance.collection('budget').doc(budgetDoc.id);
        await budgetRef.update({'current_amount': updatedAmount});
      }
    }
  }

  // Function to get the user's bank balance from Firebase Firestore
  Future getUserBankBalance(String? uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('user_bank').doc(uid).get();

    if (snapshot.exists) {
      return snapshot.data()?['balance'];
    }

    return null; // Return null if the document does not exist
  }

  // Function to update the user's bank balance in the database
  Future<void> updateUserBankBalance(String? userId, int newBalance) async {
    try {
      // Replace this with the code to update the user's balance in your database
      // Example using Firebase Firestore:
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'bankBalance': newBalance});
      }
    } catch (e) {
      // Handle any errors that occur during the update operation
      print('Error updating balance: $e');
      // You may want to throw an exception or handle the error differently here.
    }
  }

  void deleteRecord(Map<String, dynamic> item) async {
    String documentId = item['documentId'];
    String uid = currentUserUID;
    int amount = int.parse(item['amount']);
    double doubleAmount = double.parse(item['amount']);
    try {
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(documentId)
          .delete();
      // Remove the item from the dataList
      firebaseController.dataList.removeWhere(
          (element) => element['documentId'] == item['documentId']);

      if (item['type'] == 'Income') {
        if (uid != "") {
          // Check if a document with the given UID exists
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .collection('user_bank')
              .doc(uid)
              .get();
          if (snapshot.exists) {
            // If the document exists, update the balance field
            Map<String, dynamic>? data =
                snapshot.data() as Map<String, dynamic>?;
            if (data != null) {
              await FirebaseFirestore.instance
                  .collection('user_bank')
                  .doc(uid)
                  .update({
                'balance': FieldValue.increment(-amount), // Subtract the amount
              });
            }
          }
        }
      } else {
        if (uid != "") {
          // Check if a document with the given UID exists
          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .collection('user_bank')
              .doc(uid)
              .get();
          if (snapshot.exists) {
            // If the document exists, update the balance field
            Map<String, dynamic>? data =
                snapshot.data() as Map<String, dynamic>?;
            if (data != null) {
              await FirebaseFirestore.instance
                  .collection('user_bank')
                  .doc(uid)
                  .update({
                'balance': FieldValue.increment(amount), // increment
              });
            }
          }
          // update the budget
        }
      }
      await updateBudgetAfterDelete(uid, item['category'], doubleAmount);
    } catch (e) {
      print('Error deleting record: $e');
    }
  }

  Future<void> updateBudgetAfterDelete(
      String uid, String category, double amount) async {
    // Fetch the budget document for the specified category
    QuerySnapshot budgetQuery = await FirebaseFirestore.instance
        .collection('budget')
        .where('uid', isEqualTo: uid)
        .where('category', isEqualTo: category)
        .get();

    if (budgetQuery.docs.isNotEmpty) {
      for (QueryDocumentSnapshot budgetDoc in budgetQuery.docs) {
        // Update the budget amount for the specified category
        DocumentReference budgetRef =
            FirebaseFirestore.instance.collection('budget').doc(budgetDoc.id);
        await budgetRef
            .update({'current_amount': FieldValue.increment(-amount)});
      }
    }
  }

  Future<void> updateRecord(Map<String, dynamic> item) async {
    try {
      String documentId = item['documentId'];
      await FirebaseFirestore.instance
          .collection('transaction')
          .doc(documentId)
          .update(item);
    } catch (e) {
      print('Error updating record: $e');
    }
  }

  Future<void> _selectDate(
      BuildContext context, Map<String, dynamic> item) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(item['date']),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != item['date']) {
      setState(() {
        item['date'] = picked.toLocal().toString(); // Update the date
      });
    }
  }
}
