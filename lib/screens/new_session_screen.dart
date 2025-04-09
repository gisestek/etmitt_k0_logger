import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../translations.dart';
import '../utils/calculations.dart';

class NewSessionScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final String language;

  const NewSessionScreen({
    super.key,
    required this.currentUser,
    required this.language,
  });

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
        stdDev = calculateStandardDeviation(k0Values);
      });
    }
  }

  Future<void> _finishSession() async {
    if (k0Values.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = widget.currentUser['userId'];
    final key = 'sessions_$userId';
    final existingData = prefs.getStringList(key) ?? [];

    final sessionData = jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'values': k0Values,
      'stdDev': stdDev,
    });

    existingData.add(sessionData);
    await prefs.setStringList(key, existingData);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translated('new_training_session', widget.language)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter K0 value'),
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
            const Spacer(),
            ElevatedButton(
              onPressed: _finishSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(translated('finish_session', widget.language)),
            ),
          ],
        ),
      ),
    );
  }
}
