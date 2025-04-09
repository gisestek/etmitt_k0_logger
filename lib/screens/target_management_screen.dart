import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../translations.dart';

class TargetManagementScreen extends StatefulWidget {
  final Map<String, dynamic> site;
  final String language;

  const TargetManagementScreen({
    super.key,
    required this.site,
    required this.language,
  });

  @override
  State<TargetManagementScreen> createState() => _TargetManagementScreenState();
}

class _TargetManagementScreenState extends State<TargetManagementScreen> {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _mgrsTargetController = TextEditingController();

  List<Map<String, dynamic>> targets = [];

  @override
  void initState() {
    super.initState();
    targets = List<Map<String, dynamic>>.from(widget.site['targets']);
  }

  Future<void> _saveTargets() async {
    final prefs = await SharedPreferences.getInstance();
    final siteList = prefs.getStringList('sites') ?? [];

    final updatedSiteList = siteList.map((siteString) {
      final site = jsonDecode(siteString);
      if (site['siteName'] == widget.site['siteName']) {
        site['targets'] = targets;
      }
      return jsonEncode(site);
    }).toList();

    await prefs.setStringList('sites', updatedSiteList);
  }

  void _addTarget() {
    final distance = _distanceController.text.trim();
    final direction = _directionController.text.trim();
    final mgrsTarget = _mgrsTargetController.text.trim();

    if (mgrsTarget.isEmpty && (distance.isEmpty || direction.isEmpty)) {
      return;
    }

    setState(() {
      targets.add({
        'distance': distance,
        'direction': direction,
        'mgrsTarget': mgrsTarget,
      });
      _distanceController.clear();
      _directionController.clear();
      _mgrsTargetController.clear();
    });

    _saveTargets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Targets for ${widget.site['siteName']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Distance (meters)'),
            ),
            TextField(
              controller: _directionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Direction (mils)'),
            ),
            TextField(
              controller: _mgrsTargetController,
              decoration: const InputDecoration(labelText: 'MGRS Target (optional)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTarget,
              child: Text(translated('add_target', widget.language)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: targets.length,
                itemBuilder: (context, index) {
                  final target = targets[index];
                  return ListTile(
                    title: Text(target['mgrsTarget']?.isNotEmpty == true
                        ? target['mgrsTarget']
                        : 'Distance: ${target['distance']} m, Direction: ${target['direction']} mils'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
