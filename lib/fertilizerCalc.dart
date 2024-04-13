import 'dart:convert';

import 'package:crop_disease_detection/fruitModel.dart';
import 'package:flutter/material.dart';

class FertilizerCalculatorScreen extends StatefulWidget {
  const FertilizerCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<FertilizerCalculatorScreen> createState() =>
      _FertilizerCalculatorScreenState();
}

class _FertilizerCalculatorScreenState
    extends State<FertilizerCalculatorScreen> {
  @override
  void initState() {
    super.initState();
    calculateFertilizer(1);
  }

  List<Fruit> parseFruits(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Fruit>((json) => Fruit.fromJson(json)).toList();
  }

  void calculateFertilizer(int numberOfTrees) {
    // Fetch fruits data from the JSON file or API
    String fruitsJson = '''
    [
        {
            "name": "Persimmon",
            "nutritions": {
                "calories": 81,
                "fat": 0.0,
                "sugar": 18.0,
                "carbohydrates": 18.0,
                "protein": 0.0
            }
        },
        {
            "name": "Strawberry",
            "nutritions": {
                "calories": 29,
                "fat": 0.4,
                "sugar": 5.4,
                "carbohydrates": 5.5,
                "protein": 0.8
            }
        },
        {
            "name": "Banana",
            "nutritions": {
                "calories": 96,
                "fat": 0.2,
                "sugar": 17.2,
                "carbohydrates": 22.0,
                "protein": 1.0
            }
        },
    ]
  ''';
    List<Fruit> fruits = parseFruits(fruitsJson);
    // For demonstration purposes, let's just print the nutritional values
    fruits.forEach((fruit) {
      print('Fruit: ${fruit.name}');
      print('Calories: ${fruit.calories}');
      print('Fat: ${fruit.fat}');
      print('Sugar: ${fruit.sugar}');
      print('Carbohydrates: ${fruit.carbohydrates}');
      print('Protein: ${fruit.protein}');
      print('--------------------------------');
    });

    // Calculate average nutritional values
    double totalCalories = 0;
    double totalFat = 0;
    double totalSugar = 0;
    double totalCarbohydrates = 0;
    double totalProtein = 0;

    for (var fruit in fruits) {
      totalCalories += fruit.calories;
      totalFat += fruit.fat;
      totalSugar += fruit.sugar;
      totalCarbohydrates += fruit.carbohydrates;
      totalProtein += fruit.protein;
    }
    double averageCalories = totalCalories / fruits.length;
    double averageFat = totalFat / fruits.length;
    double averageSugar = totalSugar / fruits.length;
    double averageCarbohydrates = totalCarbohydrates / fruits.length;
    double averageProtein = totalProtein / fruits.length;

    // Calculate fertilizer recommendations based on average nutritional values and number of trees
    // You can define your fertilizer calculation logic here based on your specific requirements
    // For example, you can use a formula or lookup table to determine fertilizer recommendations

    // Print fertilizer recommendations
    print('Fertilizer Recommendations for $numberOfTrees trees:');
    print('---------------------------------------------------');
    print('Average Calories per fruit: ${averageCalories.toStringAsFixed(2)}');
    print('Average Fat per fruit: ${averageFat.toStringAsFixed(2)}');
    print('Average Sugar per fruit: ${averageSugar.toStringAsFixed(2)}');
    print(
        'Average Carbohydrates per fruit: ${averageCarbohydrates.toStringAsFixed(2)}');
    print('Average Protein per fruit: ${averageProtein.toStringAsFixed(2)}');
    print('---------------------------------------------------');
    print(
        'Your fertilizer recommendations based on the number of trees can be calculated here.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //
        ],
      ),
    );
  }
}
