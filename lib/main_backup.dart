// ETMITT K0 Logger - Flutter Prototype

import 'package:flutter/material.dart';
import 'dart:math';


void main() {
  runApp(const ETMITTLoggerApp());
}

class ETMITTLoggerApp extends StatelessWidget {
  const ETMITTLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETMITT K0 Logger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('K0 Training Sessions')),
      body: Center(
        child: ElevatedButton(
          child: const Text('New Session'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewSessionScreen()),
          ),
        ),
      ),
    );
  }
}

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key});

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final List<double> k0Values = [];
  final TextEditingController _valueController = TextEditingController();
  double? stdDev;

  void _addK0Value() {
    final value = double.tryParse(_valueController.text);
    if (value != null) {
      setState(() {
        k0Values.add(value);
        _valueController.clear();
        stdDev = _calculateStandardDeviation(k0Values);
      });
    }
  }

  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSq = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b);
    return sqrt(sumSq / values.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New K0 Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter K0 value',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addK0Value,
              child: const Text('Add Value'),
            ),
            const SizedBox(height: 20),
            Text('Values: ${k0Values.join(', ')}'),
            if (stdDev != null)
              Text('Standard Deviation: ${stdDev!.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}


