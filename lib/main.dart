import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BMICalculatorScreen(),
    );
  }
}

class BMICalculatorModel extends ChangeNotifier {
  double _bmi = 0;
  String _heightUnit = 'cm';

  double get bmi => _bmi;
  String get heightUnit => _heightUnit;

  void setHeightUnit(String unit) {
    _heightUnit = unit;
    notifyListeners();
  }

  void calculateBMI(double height, double weight) {
    if (height > 0 && weight > 0) {
      double calculatedHeight = height;
      if (_heightUnit == 'feet') {
        calculatedHeight *= 30.48; // Convert feet to centimeters
      }
      double bmi =
          weight / ((calculatedHeight / 100) * (calculatedHeight / 100));
      _bmi = bmi;
    } else {
      _bmi = 0;
    }
    notifyListeners();
  }

  String getBMIStatus(double height, double weight) {
    double calculatedHeight = height;
    if (_heightUnit == 'feet') {
      calculatedHeight *= 30.48; // Convert feet to centimeters
    }
    if (_bmi < 18.5) {
      double weightDifference =
          (18.5 * ((calculatedHeight / 100) * (calculatedHeight / 100))) -
              weight;
      return 'Underweight! You need to gain ${weightDifference.toStringAsFixed(2)} kg to reach a normal BMI.';
    } else if (_bmi >= 18.5 && _bmi <= 24.9) {
      return 'Normal weight';
    } else if (_bmi > 24.9 && _bmi <= 29.9) {
      double weightDifference = weight -
          (24.9 * ((calculatedHeight / 100) * (calculatedHeight / 100)));
      return 'Overweight! You need to lose ${weightDifference.toStringAsFixed(2)} kg to reach a normal BMI.';
    } else {
      double weightDifference = weight -
          (24.9 * ((calculatedHeight / 100) * (calculatedHeight / 100)));
      return 'Obesity! You need to lose ${weightDifference.toStringAsFixed(2)} kg to reach a normal BMI.';
    }
  }
}

class BMICalculatorScreen extends StatelessWidget {
  const BMICalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BMICalculatorModel(),
      child: _BMICalculatorScreenStateful(),
    );
  }
}

class _BMICalculatorScreenStateful extends StatefulWidget {
  @override
  _BMICalculatorScreenState createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<_BMICalculatorScreenStateful> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bmiModel = Provider.of<BMICalculatorModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(
        
        height: 500,
        decoration: BoxDecoration(
          color: const Color.fromARGB(248, 245, 201, 107),
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'BMI CALCULATOR',
              style: TextStyle(
                color: Colors.green, // Set text color to green
                fontSize: 32.0, // Set font size to 32
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Height (${bmiModel.heightUnit})',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: bmiModel.heightUnit,
                  onChanged: (String? newValue) {
                    bmiModel.setHeightUnit(newValue!);
                  },
                  items: <String>['cm', 'feet'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  style: const TextStyle(color: Colors.green, fontSize: 20),
                  underline: Container(
                    height: 2,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                double height = double.tryParse(_heightController.text) ?? 0;
                double weight = double.tryParse(_weightController.text) ?? 0;
                bmiModel.calculateBMI(height, weight);
              },
              child: const Text('Calculate BMI'),
            ),
            const SizedBox(height: 10),
            Text(
              'BMI: ${bmiModel.bmi.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            bmiModel.bmi > 0
                ? Column(
                    children: [
                      const Text(
                        'Normal BMI Range: 18.5 - 24.9',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bmiModel.getBMIStatus(
                            double.tryParse(_heightController.text) ?? 0,
                            double.tryParse(_weightController.text) ?? 0),
                        style: TextStyle(
                          fontSize: 20,
                          color: bmiModel.bmi >= 18.5 && bmiModel.bmi <= 24.9
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
