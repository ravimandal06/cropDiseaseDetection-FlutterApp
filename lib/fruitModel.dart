import 'dart:convert';

class Fruit {
  final String name;
  final double calories;
  final double fat;
  final double sugar;
  final double carbohydrates;
  final double protein;

  Fruit({
    required this.name,
    required this.calories,
    required this.fat,
    required this.sugar,
    required this.carbohydrates,
    required this.protein,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      name: json['name'],
      calories: json['nutritions']['calories'].toDouble(),
      fat: json['nutritions']['fat'].toDouble(),
      sugar: json['nutritions']['sugar'].toDouble(),
      carbohydrates: json['nutritions']['carbohydrates'].toDouble(),
      protein: json['nutritions']['protein'].toDouble(),
    );
  }
}
