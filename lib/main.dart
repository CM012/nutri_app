import 'dart:io';
import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:english_words/english_words.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Nutrition App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('/Users/charles/Documents/MyProjects/ComputerVision/Recommender/APP/flutter5/lib/fotos/Homepage.jpeg',
              width:400,
              height:200,
              fit: BoxFit.contain,),
            ),
            const SizedBox(height: 20),
            const Text(
              'Personalise your 3D printed macro food '
                  'and stay healthy!',
              style: TextStyle(fontSize: 24),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NutritionCalculatorPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  color: const Color.fromARGB(255, 49, 203, 234),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Start Now',
                  style: TextStyle(fontSize: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionCalculatorPage extends StatefulWidget {
  const NutritionCalculatorPage({super.key});

  @override
  _NutritionCalculatorPageState createState() => _NutritionCalculatorPageState();
}

class _NutritionCalculatorPageState extends State<NutritionCalculatorPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _carbController = TextEditingController(text: '100');
  final TextEditingController _proteinController = TextEditingController(text: '20');
  final TextEditingController _fatController = TextEditingController(text: '20');

  String _sex = 'male';
  String _activityLevel = 'sedentary';
  String _dietPlan = 'balance';
  String _result = '';

  double calculateBMR(double weight, double height, int age, String sex) {
    if (sex == "male") {
      return 66 + (6.3 * weight) + (12.9 * height) - (6.8 * age);
    } else {
      return 655 + (4.3 * weight) + (4.7 * height) - (4.7 * age);
    }
  }

  double calculateDailyCalories(double bmr, String activityLevel) {
    switch (activityLevel) {
      case "sedentary":
        return bmr * 1.2;
      case "lightly active":
        return bmr * 1.375;
      case "moderately active":
        return bmr * 1.55;
      case "very active":
        return bmr * 1.725;
      default:
        return bmr;
    }
  }

  void calculateNutrition() {
    final double? weight = double.tryParse(_weightController.text);
    final double? height = double.tryParse(_heightController.text);
    final int? age = int.tryParse(_ageController.text);

    if (weight == null || height == null || age == null) {
      setState(() {
        _result = 'Please enter valid values for weight, height, and age';
      });
      return;
    }

    final double weightInLb = weight * 2.20462;
    final double heightInInches = height * 39.3701;

    final double bmr = calculateBMR(weightInLb, heightInInches, age, _sex);
    final double calories = calculateDailyCalories(bmr, _activityLevel);

    double carbIntake, proteinIntake, fatIntake;

    switch (_dietPlan) {
      case "balance":
        carbIntake = calories * 0.65 / 4;
        proteinIntake = calories * 0.125 / 4;
        fatIntake = calories * 0.225 / 9;
        break;
      case "low fat":
        carbIntake = calories * 0.725 / 4;
        proteinIntake = calories * 0.125 / 4;
        fatIntake = calories * 0.15 / 9;
        break;
      case "low carb":
        carbIntake = calories * 0.55 / 4;
        proteinIntake = calories * 0.15 / 4;
        fatIntake = calories * 0.30 / 9;
        break;
      case "high protein":
        carbIntake = calories * 0.725 / 4;
        proteinIntake = calories * 0.15 / 4;
        fatIntake = calories * 0.125 / 9;
        break;
      default:
        carbIntake = proteinIntake = fatIntake = 0;
    }

    final double currentCarb = double.tryParse(_carbController.text) ?? 100;
    final double currentProtein = double.tryParse(_proteinController.text) ?? 20;
    final double currentFat = double.tryParse(_fatController.text) ?? 20;

    final double carbNeeded = carbIntake - currentCarb;
    final double proteinNeeded = proteinIntake - currentProtein;
    final double fatNeeded = fatIntake - currentFat;

    final List<List<double>> W = [
      [20, 20.1, 9],
      [1.45, 9.02, 2],
      [0, 0.38, 15]
    ];

    final List<double> y = [carbNeeded, proteinNeeded, fatNeeded];

    List<double> solution = [0, 0, 0]; // Placeholder for optimization logic

    setState(() {
      _result = '''
      Your daily calorie needs are: ${calories.toStringAsFixed(2)}
      Your protein intake should be ${proteinIntake.toStringAsFixed(2)} grams per day
      Your carbohydrates intake should be ${carbIntake.toStringAsFixed(2)} grams per day
      Your fat intake should be ${fatIntake.toStringAsFixed(2)} grams per day
      We need to print following amount: ${solution.map((e) => e.toStringAsFixed(2)).join(', ')}
      ''';
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(result: _result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Calculator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight in KG'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height in M'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _sex,
                items: ['male', 'female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _sex = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _activityLevel,
                items: [
                  'sedentary',
                  'lightly active',
                  'moderately active',
                  'very active'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _activityLevel = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _dietPlan,
                items: ['balance', 'low fat', 'low carb', 'high protein'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _dietPlan = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _carbController,
                decoration: const InputDecoration(labelText: 'Current Carb Intake (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Current Protein Intake (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Current Fat Intake (g)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculateNutrition,
                child: const Text('Calculate My Macros'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String result;

  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('/Users/charles/Documents/MyProjects/ComputerVision/Recommender/APP/flutter5/lib/fotos/Loading.jpg'),
                  fit: BoxFit.fill, ),
                  shape: BoxShape.circle 
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraOptionsPage()),
                    //MaterialPageRoute(builder: (context) => CameraPage()),
                  );
                },
                child: const Text('Take picture of your food'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
      );
      await _controller!.initialize();
    } catch (e) {
      print(e);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    try{
    final image = await _controller!.takePicture();
    // Do something with the image, e.g., save or display it
    print('Picture taken: ${image.path}');

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PrintMyFoodPage(),
        ),
      );
    }
    }catch (e) {
    print('Error taking picture: $e');
  }


  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isCameraInitialized && _controller != null)
              SizedBox(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
                width: 300,
                height: 200,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCameraInitialized ? _takePicture : null,
              child: const Text('Take Picture'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
class CameraOptionsPage extends StatelessWidget {
  const CameraOptionsPage({super.key});


  //File? _image;
  //final picker = ImagePickerCameraDelegateOptions();

  //Future getImage() async {
    //final pickedImage = await picker.pickImage(
        //source: ImageSource.gallery
    //);

    //setState((){
      //if (pickedImage != null) {
        //_image = File(pickedImage.path);
      //} else{
        //print("No image is picked");
      //}
        //});
  //}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Options'),
      ),
      body: Center(
        child: //_image == null ? Text('No picture is picked'):
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraPage()),
                  );
                },
                child: const Text('Choose from Gallery'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraPage()),
                  );
                },
                child: const Text('Take Photo Now'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }

  //void setState(Null Function() param0) {}
//}

extension on ImagePickerCameraDelegateOptions {
  pickImage({required ImageSource source}) {}
}

class camerapage extends StatelessWidget{
  const camerapage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🖨️ Printing the food you need...',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrintMyFoodPage()),
                );
              },
              child: const Text('Take photo now'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrintMyFoodPage()),
                );
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}


class PrintMyFoodPage extends StatelessWidget {
  const PrintMyFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print My Food'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🖨️ Printing the food you need...',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}