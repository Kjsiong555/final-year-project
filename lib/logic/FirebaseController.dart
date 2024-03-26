import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class FirebaseController extends GetxController {
  RxList dataList = [].obs;
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  late String currentUserUID;
  RxList budgetItems = [].obs;
  User? user = FirebaseAuth.instance.currentUser;
  Timestamp todayTimestamp = Timestamp.fromDate(DateTime.now());
  Map<String, dynamic> itemForBudget = {};
    Future<void> updateBudgetWithTransaction() async {
      try {
        print('Starting updateBudgetWithTransaction');

        final String uid = user?.uid ?? '';
        final WriteBatch batch = FirebaseFirestore.instance.batch();
        String expenseCategory = itemForBudget['category'] ?? '';
        double amount = double.parse(itemForBudget['amount'].toString());

        print(
            'Processing data: Expense Category: $expenseCategory, Amount: $amount');

        // Check if there's a budget category for the expense category
        final QuerySnapshot budgetQuery = await FirebaseFirestore.instance
          .collection('budget')
          .where('uid', isEqualTo: uid)
          .where('category',
              isEqualTo: expenseCategory.trim()) // Ensure trimming spaces
          .get();


        if (budgetQuery.docs.isNotEmpty) {
          for (QueryDocumentSnapshot budgetDoc in budgetQuery.docs) {
            try {
              final double currentAmount =
                  (budgetDoc['current_amount'] ?? 0).toDouble();
              final double updatedAmount = currentAmount + amount;

              print(
                  'Updating budget: Expense Category: $expenseCategory, Document ID: ${budgetDoc.id}, Current Amount: $currentAmount, New Amount: $amount, Updated Amount: $updatedAmount');

              // Update the current_amount in the budget document
              final DocumentReference budgetRef = FirebaseFirestore.instance
                  .collection('budget')
                  .doc(budgetDoc.id);
              batch.update(budgetRef, {'current_amount': updatedAmount});
            } catch (e) {
              print('Error updating budget document: $e');
            }
          }
        } else {
          print(
              'No budget category found for expense category: $expenseCategory');
          // You can handle this case if needed, e.g., by logging a message or taking some other action.
        }
      // Commit the batched write
      await batch.commit();

        print('Finished updateBudgetWithTransaction');
      } catch (e) {
        print('Error in updateBudgetWithTransaction: $e');
      }
    }

  Future<void> fetchDataFromFirebase(
      String currentUserUID, DateTime startDate, DateTime endDate) async {
    currentUserUID = currentUserUID;
    String formattedStartDate =
        '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    String formattedEndDate =
        '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('transaction')
        .where('uid', isEqualTo: currentUserUID)
        .where('date', isGreaterThanOrEqualTo: formattedStartDate)
        .where('date', isLessThanOrEqualTo: formattedEndDate)
        .get();

    List<Map<String, dynamic>> dataItems = [];
    querySnapshot.docs.forEach((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      dataItems.add(data);
    });

    dataList.assignAll(dataItems);
    dataList.refresh();
  }

  void setDateRangeFromSelection(String selectedDateRange) {
    DateTime now = DateTime.now();
    if (selectedDateRange == 'Today') {
      startDate.value = DateTime(now.year, now.month, now.day);
      endDate.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (selectedDateRange == 'This week') {
      int dayOfWeek = now.weekday;
      startDate.value = now.subtract(Duration(days: dayOfWeek - 1));
      endDate.value = startDate.value
          .add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    } else if (selectedDateRange == 'This month') {
      startDate.value = DateTime(now.year, now.month);
      endDate.value = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else if (selectedDateRange == 'This year') {
      startDate.value = DateTime(now.year);
      endDate.value = DateTime(now.year + 1, 12, 0, 23, 59, 59);
    }
  }

  void addItemToDataList(Map<String, dynamic> itemData) {
    DateTime itemDate = DateTime.parse(itemData['date']);
    if (itemDate.isAtSameMomentAs(startDate.value) ||
        (itemDate.isAfter(startDate.value) &&
            itemDate.isBefore(endDate.value))) {
      dataList.add(itemData);
      dataList.refresh();
    }
  }
}
