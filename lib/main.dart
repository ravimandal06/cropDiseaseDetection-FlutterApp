// import 'dart:convert';
// import 'dart:io' show File;
// import 'package:crop_disease_detection/textStyle.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   dynamic _image;
//   String? _prediction;

//   Future _chooseImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _image = kIsWeb ? pickedFile : File(pickedFile.path);
//         _prediction = null;
//       });
//     }
//   }

// Future _predictDisease() async {
//     if (_image == null) {
//       return;
//     }

//     const String serverUrl = "http://192.168.18.72:8000/get_prediction";

//     try {
//       var response = await http.get(Uri.parse(serverUrl));
//       var jsonData = json.decode(response.body);

//       setState(() {
//         _prediction = jsonData['prediction'];
//       });

//       print('Prediction: $_prediction');
//     } catch (e) {
//       print(e);
//     }
//   }

//   TextFonts texts = TextFonts();
//   int _selectedIndex = -1;

//   final List<String> _boxWords = [
//     "Apple",
//     "Banana",
//     "Cherry",
//     "Date",
//     "Elderberry",
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(
//       children: [
//         SizedBox(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Plantix",
//                 style: texts.quickAction,
//               ),
//               const Icon(Icons.more_vert_rounded),
//             ],
//           ),
//         ),
//         Container(
//           height: 16,
//         ),
//         Container(
//           child: Stack(
//             children: [
//               AnimatedContainer(
//                 height: 80,
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: _boxWords.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedIndex = index;
//                         });
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                         margin: const EdgeInsets.only(right: 12),
//                         width: 80,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 12,
//                             color: _selectedIndex == index
//                                 ? Colors.red
//                                 : Colors.transparent,
//                           ),
//                           borderRadius: BorderRadius.circular(100),
//                         ),
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: Image.asset('assets/FlowerLotus.png'),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               //
//               Padding(
//                 padding: const EdgeInsets.only(top: 73),
//                 child: AnimatedOpacity(
//                   duration: const Duration(milliseconds: 300),
//                   opacity: _selectedIndex != -1 ? 1.0 : 0.0,
//                   child: Container(
//                     height: 100,
//                     width: double.infinity,
//                     // margin: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(15),
//                       color: _selectedIndex != -1
//                           ? Colors.red
//                           : Colors.transparent,
//                     ),
//                     child: Center(
//                       child: _selectedIndex != -1
//                           ? Text(
//                               _boxWords[_selectedIndex],
//                               style: const TextStyle(fontSize: 18),
//                             )
//                           : Container(),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     ));
//   }
// }

import 'dart:convert';

import 'package:crop_disease_detection/fertilizerCalc.dart';
import 'package:crop_disease_detection/flutterAdapter.dart';
import 'package:crop_disease_detection/hiveClass.dart';
import 'package:crop_disease_detection/product_list_screen.dart';
import 'package:crop_disease_detection/tab_controller.dart';
import 'package:crop_disease_detection/textStyle.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FruitSelectionScreen(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  final List<String> selectedFruits;
  const ExamplePage({Key? key, required this.selectedFruits}) : super(key: key);

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  late TextTheme textTheme;
  TextFonts texts = TextFonts();
  final String apiKey = "2d667c219c86418688d150639240804";
  final String location =
      "Janakpur,Nepal"; // Change this to the desired location

  Map<String, dynamic> weatherData = {};
  String? currentDate;
  double? temperature;
  late Box<Fruit> fruitBox;
  List<Fruit> savedFruits = [];

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
    fetchWeatherData();
    setCurrentDate();
    _initHive();
    _loadSavedFruits();
    // getFruitInfo('apple');
  }

  @override
  void didChangeDependencies() {
    textTheme = Theme.of(context).textTheme;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Future<void> _initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(FruitAdapter());
    fruitBox = await Hive.openBox<Fruit>('fruits');
  }

  Future<void> _loadSavedFruits() async {
    savedFruits = fruitBox.values.toList();
    setState(() {}); // Update the UI
    debugPrint(
        "printing the fruits herereeifnirninr0------> ${savedFruits.length}");
  }

  Future<void> fetchWeatherData() async {
    final Uri uri = Uri.parse(
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$location');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          temperature = weatherData['current']['temp_c'];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Future<void> getFruitInfo(String fruitName) async {
  //   final String apiUrl = "https://www.fruityvice.com/api/fruit/$fruitName";

  //   final response = await http.get(Uri.parse(apiUrl));

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> fruitData = json.decode(response.body);
  //     // Print the retrieved data
  //     print("Name: ${fruitData["name"]}");
  //     print("Genus: ${fruitData["genus"]}");
  //     print("Family: ${fruitData["family"]}");
  //     print("Order: ${fruitData["order"]}");
  //     // Add more fields as needed
  //   } else {
  //     // Print an error message if the request failed
  //     print("Failed to fetch fruit data. Status code: ${response.statusCode}");
  //   }
  // }
  // Future<void> getFruitInfo(String fruitName) async {
  //   final String apiUrl = "https://www.fruityvice.com/api/fruit/$fruitName";

  //   final response = await http.get(Uri.parse(apiUrl));

  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> fruitData = json.decode(response.body);
  //     // Print the entire fruitData map
  //     print("Fruit Data: $fruitData");

  //     // Alternatively, you can print each key-value pair individually
  //     fruitData.forEach((key, value) {
  //       print("$key: $value");
  //     });
  //   } else {
  //     // Print an error message if the request failed
  //     print("Failed to fetch fruit data. Status code: ${response.statusCode}");
  //   }
  // }

  void setCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('d MMM');
    setState(() {
      currentDate = 'Today, ${formatter.format(now)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("printing the fruits details --- > ${getFruitInfo('apple')}");
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'AgriX',
            style: texts.screenHeading,
          ),
          actions: const [Icon(Icons.more_vert_rounded)]),
      body: SingleChildScrollView(
        child: SizedBox(
          height: 1000,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(
              //   width: 400,
              //   child: AspectRatio(
              //     aspectRatio: 18 / 9,
              //     child: TabContainer(
              //       borderRadius: const BorderRadius.only(
              //           bottomLeft: Radius.circular(24),
              //           bottomRight: Radius.circular(24)),
              //       tabEdge: TabEdge.top,
              //       curve: Curves.easeIn,
              //       transitionBuilder: (child, animation) {
              //         animation = CurvedAnimation(
              //             curve: Curves.easeIn, parent: animation);
              //         return SlideTransition(
              //           position: Tween(
              //             begin: const Offset(0.9, 0.0),
              //             end: const Offset(0.0, 0.0),
              //           ).animate(animation),
              //           child: FadeTransition(
              //             opacity: animation,
              //             child: child,
              //           ),
              //         );
              //       },
              //       colors: const <Color>[
              //         Color(0xffD3BCED),
              //         Color(0xffD3BCED),
              //         Color(0xffD3BCED),
              //       ],
              //       selectedTextStyle:
              //           textTheme.bodyMedium?.copyWith(fontSize: 15.0),
              //       unselectedTextStyle:
              //           textTheme.bodyMedium?.copyWith(fontSize: 13.0),
              //       tabs: _getTabs1(),
              //       children: _getChildren1(),
              //     ),
              //   ),
              // ),
              // SizedBox(
              //   height: 24,
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.selectedFruits.length,
                        itemBuilder: (context, index) {
                          final fruit = widget.selectedFruits[index];

                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 80,
                            height: 80,
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
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 6,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/fruits/$fruit.png"),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const FruitSelectionScreen(),
                          ));
                        },
                        child: Container(
                          width: 65,
                          height: 40,
                          decoration: BoxDecoration(
                              color: const Color(0xffF7F7F7),
                              borderRadius: BorderRadius.circular(30)),
                          child: const Icon(Icons.add_circle_outline_rounded,
                              size: 30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Heal your crop",
                      style: texts.buttonText,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xffF7F7F7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Image.asset(
                                    "assets/photo.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                ),
                                SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Image.asset(
                                    "assets/medical.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded),
                                SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: Image.asset(
                                    "assets/pills.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Take a\npicture",
                                    textAlign: TextAlign.center,
                                    style: texts.otherPgHeading,
                                  ),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  Text(
                                    "See\ndiagnosis",
                                    textAlign: TextAlign.center,
                                    style: texts.otherPgHeading,
                                  ),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  Text(
                                    "Get\nmedicine",
                                    textAlign: TextAlign.center,
                                    style: texts.otherPgHeading,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 50,
                              width: 280,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        const MaterialStatePropertyAll(
                                      Color(0xff0158DA),
                                    ),
                                    shadowColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black),
                                    elevation:
                                        MaterialStateProperty.all<double>(10),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    //
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         const FertilizerCalculatorScreen(),
                                    //   ),
                                    // );
                                    //
                                  },
                                  child: Text(
                                    "Take a Picture",
                                    style: texts.formInput
                                        .copyWith(color: Colors.white),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Weather",
                      style: texts.buttonText,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    // Text(
                    //   "Current temperature: $temperature °C",
                    //   style: const TextStyle(fontSize: 20),
                    // ),
                    weatherData.isEmpty
                        ? const CircularProgressIndicator()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$currentDate",
                                    style: texts.roomDetailParagraph,
                                  ),
                                  Text(
                                    "24 °C",
                                    style: texts.profileHeading,
                                  ),
                                ],
                              ),
                              TemperatureImage(
                                temperature: weatherData['current']['temp_c'],
                              ),
                            ],
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  List<String> imagePaths = [
    'assets/fruits/Cherry.png',
    'assets/fruits/Fig.png',
    'assets/fruits/Raspberry.png',
    'assets/fruits/Orange.png',
    // Add more image asset paths here as needed
  ];
  List<Widget> _getChildren1() {
    return List.generate(3, (index) => StepBoxes());
  }

  List<Widget> _getTabs1() {
    List<CreditCardData> cards = kCreditCards
        .map(
          (e) => CreditCardData.fromJson(e),
        )
        .toList();

    // List of image asset paths
    List<String> imagePaths = [
      'assets/sun.png',
      'assets/pills.png',
      'assets/worm.png',
      // Add more image asset paths here as needed
    ];

    // Creating a list of Widgets with different images for each tab
    List<Widget> tabImages = [];
    for (int i = 0; i < cards.length; i++) {
      // Ensure that there are enough image paths for each card
      if (i < imagePaths.length) {
        tabImages.add(Image.asset(imagePaths[i]));
      } else {
        // If there are not enough image paths, you can handle this case accordingly
        // For example, you can repeat images or use a default image
        tabImages.add(Image.asset('assets/FlowerLotus1.png'));
      }
    }

    return tabImages;
  }
}

// class Fruit {
//   final String name;
//   final double nitrogenRequirement; // in kg per acre
//   final double phosphorusRequirement; // in kg per acre
//   final double potassiumRequirement; // in kg per acre

//   Fruit({
//     required this.name,
//     required this.nitrogenRequirement,
//     required this.phosphorusRequirement,
//     required this.potassiumRequirement,
//   });
// }

class Soil {
  final double nitrogenContent; // in kg per acre
  final double phosphorusContent; // in kg per acre
  final double potassiumContent; // in kg per acre

  Soil({
    required this.nitrogenContent,
    required this.phosphorusContent,
    required this.potassiumContent,
  });
}

class Fertilizer {
  final String name;
  final double nitrogenContent; // percentage
  final double phosphorusContent; // percentage
  final double potassiumContent; // percentage

  Fertilizer({
    required this.name,
    required this.nitrogenContent,
    required this.phosphorusContent,
    required this.potassiumContent,
  });
}

List<Fertilizer> fertilizers = [
  Fertilizer(
      name: 'apple',
      nitrogenContent: 10,
      phosphorusContent: 10,
      potassiumContent: 10),
  // Add more fertilizers with their respective nutrient contents
];

// Future<void> getFruitInfo(String fruitName) async {
//   final String apiUrl = "https://www.fruityvice.com/api/fruit/$fruitName";

//   final response = await http.get(Uri.parse(apiUrl));

//   if (response.statusCode == 200) {
//     final Map<String, dynamic> fruitData = json.decode(response.body);
//     // Parse fruit data
//     Fruit fruit = Fruit(
//       name: fruitData["name"],
//       nitrogenRequirement: fruitData["nitrogenRequirement"] ?? 0,
//       phosphorusRequirement: fruitData["phosphorusRequirement"] ?? 0,
//       potassiumRequirement: fruitData["potassiumRequirement"] ?? 0,
//     );

//     // Example soil data (you should replace this with real soil data)
//     Soil soil =
//         Soil(nitrogenContent: 50, phosphorusContent: 30, potassiumContent: 40);

//     // Calculate recommended fertilizer
//     Fertilizer recommendedFertilizer = calculateFertilizer(fruit, soil);
//     print(
//         "Recommended fertilizer for ${fruit.name}: ${recommendedFertilizer.name}");
//   } else {
//     // Print an error message if the request failed
//     print("Failed to fetch fruit data. Status code: ${response.statusCode}");
//   }
// }

// Function to calculate recommended fertilizer
// Fertilizer calculateFertilizer(Fruit fruit, Soil soil) {
//   // Calculate the difference between the fruit's requirements and soil content
//   double nitrogenDifference = fruit.nitrogenRequirement - soil.nitrogenContent;
//   double phosphorusDifference =
//       fruit.phosphorusRequirement - soil.phosphorusContent;
//   double potassiumDifference =
//       fruit.potassiumRequirement - soil.potassiumContent;

//   // Find the fertilizer with the closest match to the nutrient differences
//   Fertilizer recommendedFertilizer = fertilizers.reduce((a, b) {
//     double aDiff = (a.nitrogenContent - nitrogenDifference).abs() +
//         (a.phosphorusContent - phosphorusDifference).abs() +
//         (a.potassiumContent - potassiumDifference).abs();
//     double bDiff = (b.nitrogenContent - nitrogenDifference).abs() +
//         (b.phosphorusContent - phosphorusDifference).abs() +
//         (b.potassiumContent - potassiumDifference).abs();
//     return aDiff < bDiff ? a : b;
//   });

//   return recommendedFertilizer;
// }

class CreditCardData {
  int index;
  bool locked;
  final String bank;
  final String name;
  final String number;
  final String expiration;
  final String cvc;

  CreditCardData({
    this.index = 0,
    this.locked = false,
    required this.bank,
    required this.name,
    required this.number,
    required this.expiration,
    required this.cvc,
  });

  factory CreditCardData.fromJson(Map<String, dynamic> json) => CreditCardData(
        index: json['index'],
        bank: json['bank'],
        name: json['name'],
        number: json['number'],
        expiration: json['expiration'],
        cvc: json['cvc'],
      );
}

const List<Map<String, dynamic>> kCreditCards = [
  {
    'index': 0,
    'bank': 'Aerarium',
    'name': 'John Doe',
    'number': '5234 4321 1234 4321',
    'expiration': '11/25',
    'cvc': '123',
  },
  {
    'index': 1,
    'bank': 'Aerarium',
    'name': 'John Doe',
    'number': '4234 4321 1234 4321',
    'expiration': '07/24',
    'cvc': '321',
  },
  {
    'index': 2,
    'bank': 'Aerarium',
    'name': 'John Doe',
    'number': '5234 4321 1234 4321',
    'expiration': '09/23',
    'cvc': '456',
  },
];

class StepBoxes extends StatelessWidget {
  StepBoxes({super.key});
  final List<String> boxTexts = [
    "Fertilizer\nCalculator",
    "Pests &\nDiseases",
    "Cultivation\nTips"
  ];
  final List<String> boxImages = [
    "assets/fertilizer.png", // Replace with your image paths
    "assets/worm.png",
    "assets/cultivate.png"
  ];

  TextFonts texts = TextFonts();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          boxTexts.length,
          (index) => Container(
            width: 120,
            height: 110,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 4))
              ],
              color: Colors.white, // Set your desired color here
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    boxImages[index],
                    width: 40, // Adjust image size as needed
                    height: 40,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      boxTexts[index],
                      textAlign: TextAlign.center,
                      style: texts.otherPgHeading, // Adjust font size as needed
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TemperatureImage extends StatelessWidget {
  final double temperature;

  const TemperatureImage({super.key, required this.temperature});

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/sun.png';

    // Change image path based on temperature threshold
    if (temperature <= 20) {
      imagePath = 'assets/cold_sun.png';
    } else if (temperature >= 30) {
      imagePath = 'assets/hot_sun.png';
    }

    return Image.asset(
      imagePath,
      width: 100,
      height: 100,
    );
  }
}
