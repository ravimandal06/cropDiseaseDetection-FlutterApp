import 'dart:convert';
import 'dart:math';

import 'package:crop_disease_detection/flutterAdapter.dart';
import 'package:crop_disease_detection/hiveClass.dart';
import 'package:crop_disease_detection/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FruitSelectionScreen extends StatefulWidget {
  const FruitSelectionScreen({super.key});

  @override
  _FruitSelectionScreenState createState() => _FruitSelectionScreenState();
}

class _FruitSelectionScreenState extends State<FruitSelectionScreen> {
  List<String> fruits = [
    "Apple",
    "Banana",
    "Orange",
    "Grapes",
    "Mango",
    "Pineapple",
  ];
  List<String> selectedFruits = [];
  List<String> fruitsAndVegetables = [];
  late Box<Fruit> fruitBox;

  @override
  void initState() {
    super.initState();
    _initHive();
    fetchData();
  }

  Future<void> _loadSelectedFruits() async {
    final List<Fruit> selected = fruitBox.values.toList();
    setState(() {
      selectedFruits.clear();
      selectedFruits.addAll(selected.map((fruit) => fruit.name));
    });
  }

  Future<void> _initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    // Check if FruitAdapter is already registered
    if (!Hive.isAdapterRegistered(FruitAdapter().typeId)) {
      Hive.registerAdapter(FruitAdapter());
    }

    // Check if typeId 32 corresponds to another type and register its adapter
    if (!Hive.isAdapterRegistered(32)) {
      Hive.registerAdapter(MyCustomTypeAdapter());
    }

    fruitBox = await Hive.openBox<Fruit>('fruits');
    _loadSelectedFruits(); // Call _loadSelectedFruits here
  }

  Future<String> _loadJsonFromAsset() async {
    return await rootBundle.loadString('assets/fruitsInfo.json');
  }

  Future<void> fetchData() async {
    try {
      final String jsonData = await _loadJsonFromAsset();
      final List<dynamic> data = json.decode(jsonData);
      setState(() {
        fruitsAndVegetables =
            List<String>.from(data.map((item) => item['name']));
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _saveSelectedFruits() async {
    await fruitBox.clear();
    final List<Fruit> selected =
        selectedFruits.map((name) => Fruit(id: 0, name: name)).toList();
    await fruitBox.addAll(selected);

    setState(() {
      // Update the state to reflect the changes immediately
      selectedFruits = selected.map((fruit) => fruit.name).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Fruits'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: selectedFruits.length,
                itemBuilder: (context, index) {
                  return ShakeAnimation(
                    duration: const Duration(milliseconds: 500),
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.black26,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            width: 75,
                            height: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                "assets/fruits/${selectedFruits[index]}.png",
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                fruits.add(selectedFruits[index]);
                                selectedFruits.removeAt(index);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            SizedBox(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fruitsAndVegetables.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFruits.add(fruitsAndVegetables[index]);
                          fruitsAndVegetables.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 7,
                                  spreadRadius: 2,
                                  offset: Offset(0, 4))
                            ]),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 60,
                              child: Image.asset(
                                "assets/fruits/${fruitsAndVegetables[index]}.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                            Text(fruitsAndVegetables[index]),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Save selected fruits to local storage
          _saveSelectedFruits();

          // Navigate to the homepage screen
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ExamplePage(
              selectedFruits: selectedFruits,
            ),
          ));
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}

class ShakeAnimation extends StatefulWidget {
  final Duration duration;
  final Widget child;

  const ShakeAnimation(
      {super.key, required this.duration, required this.child});

  @override
  _ShakeAnimationState createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            animation.value * 10, // Adjust the amplitude as needed
            sin(animation.value * pi) * 8, // Adjust the curve style
          ),
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
