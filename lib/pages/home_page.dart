// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_function_literals_in_foreach_calls

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/pages/budget_goal.dart';
import 'package:final_year_project/pages/pie_chart.dart';
import 'package:final_year_project/pages/record_card.dart';
import 'package:final_year_project/pages/top_card.dart';
import 'package:final_year_project/pages/user_input_expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _currentIndex = 0;
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "${user.email}",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signOut();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.logout,
              size: 32,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 1st tab
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TopCard(),
                Record_card(),
              ],
            ),
          ),

          // 2nd tab
          PieChartWidget(),
          //  3rd tab
          BudgetAndGoalPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Balance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Pie Chart',
          ),
          BottomNavigationBarItem(
            icon:
                Icon(Icons.attach_money), // Change the icon to your preference
            label: 'Budget & Goals',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
