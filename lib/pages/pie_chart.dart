// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_year_project/logic/FirebaseController.dart';
import 'package:google_fonts/google_fonts.dart';

class PieChartWidget extends StatefulWidget {
  final FirebaseController firebaseController = Get.find<FirebaseController>();

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  String selectedCategory = "Income"; // Default to "Income"

  @override
  Widget build(BuildContext context) {
    if (widget.firebaseController.dataList.isEmpty) {
      // If the data list is empty, display a message or a placeholder
      return Center(
        child: Text(
          "No data available",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // Filter the data based on the selected category
    List filteredData = widget.firebaseController.dataList
        .where((item) => item["type"] == selectedCategory)
        .toList();
    if (filteredData.length > 0) {
      // Initialize and calculate category proportions based on the filtered data
      Map<String, double> categoryProportions = {};
      filteredData.forEach((item) {
        String category = item["category"];
        double amount = double.tryParse(item["amount"]) ?? 0.0;

        // Check if the category already exists in the map
        if (categoryProportions.containsKey(category)) {
          categoryProportions[category] =
              categoryProportions[category]! + amount;
        } else {
          categoryProportions[category] = amount;
        }
      });

      // Calculate the total sum of all values
      double totalSum =
          categoryProportions.values.reduce((sum, value) => sum + value);

      // Generate a random color for each category and store them in a map
      Map<String, Color> categoryColors = {};
      categoryProportions.keys.forEach((category) {
        categoryColors[category] = getRandomColor();
      });

      // Create PieChartSectionData based on category proportions
      List<PieChartSectionData> sections =
          categoryProportions.entries.map((entry) {
        double percentage = (entry.value / totalSum) *
            100; // Calculate the percentage based on the total sum

        return PieChartSectionData(
          value: percentage,
          title:
              '${percentage.toStringAsFixed(2)}%', // Display calculated percentage
          color: categoryColors[entry.key], // Use category-specific color
        );
      }).toList();

      return SafeArea(
        child: Column(
          children: [
            Text(
              "Your Record: ",
              style: GoogleFonts.montserrat(fontSize: 28),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
              items: ["Income", "Expense"].map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  borderData: FlBorderData(show: true),
                  sectionsSpace: 3,
                  centerSpaceRadius: 150,
                  centerSpaceColor: Colors.grey[00],
                  pieTouchData: PieTouchData(
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? touchResponse) {
                      if (event is FlTapUpEvent) {
                        // Show tooltip here
                        if (touchResponse?.touchedSection != null) {
                          final section = touchResponse!.touchedSection!;
                          final category = categoryProportions.keys
                              .elementAt(section.touchedSectionIndex);

                          // Display the category using a tooltip or any other UI element
                          // For example:
                          final snackBar =
                              SnackBar(content: Text('Touched: $category'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
                height:
                    16), // Add some spacing between the chart and the legend
            Column(
              children: [
                for (var entry in categoryProportions.entries)
                  _buildLegendItem(
                    entry.key,
                    entry.value,
                    totalSum,
                    categoryColors[entry.key]!,
                  ),
              ],
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;
              });
            },
            items: ["Income", "Expense"].map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
          Text(
            "No data available",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

Color getRandomColor() {
  final Random random = Random();
  return Color.fromRGBO(
      random.nextInt(256), random.nextInt(256), random.nextInt(256), 1);
}

// Build a legend item (category name and color)
Widget _buildLegendItem(
    String category, double value, double totalSum, Color color) {
  double percentage = (value / totalSum) * 100;
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 12,
        height: 12,
        margin: EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: color, // Use the same color as the chart
          shape: BoxShape.circle,
        ),
      ),
      Text('$category (${percentage.toStringAsFixed(2)}%)'),
      SizedBox(width: 16), // Add spacing between legend items
    ],
  );
}
