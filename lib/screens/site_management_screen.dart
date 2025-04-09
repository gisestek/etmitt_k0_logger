import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../translations.dart';
import 'target_management_screen.dart';

class SiteManagementScreen extends StatefulWidget {
  final String language;

  const SiteManagementScreen({super.key, required this.language});

  @override
  State<SiteManagementScreen> createState() => _SiteManagementScreenState();
}

class _SiteManagementScreenState extends State<SiteManagementScreen> {
  List<Map<String, dynamic>> sites = [];
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _mgrsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    final prefs = await SharedPreferences.getInstance();
    final siteList = prefs.getStringList('sites') ?? [];
    setState(() {
      sites = siteList.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _saveSite() async {
    final siteName = _siteNameController.text.trim();
    final mgrs = _mgrsController.text.trim();

    if (siteName.isEmpty || mgrs.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final siteList = prefs.getStringList('sites') ?? [];

    final newSite = jsonEncode({
      'siteName': siteName,
      'mgrs': mgrs,
      'targets': [],
    });

    siteList.add(newSite);
    await prefs.setStringList('sites', siteList);

    _siteNameController.clear();
    _mgrsController.clear();
    _loadSites();
  }

  void _manageTargets(Map<String, dynamic> site) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TargetManagementScreen(
          site: site,
          language: widget.language,
        ),
      ),
    ).then((_) => _loadSites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translated('manage_sites_targets', widget.language))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _siteNameController,
              decoration: const InputDecoration(labelText: 'Site Name'),
            ),
            TextField(
              controller: _mgrsController,
              decoration: const InputDecoration(labelText: 'MGRS Coordinates'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveSite,
              child: Text(translated('add_site', widget.language)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: sites.length,
                itemBuilder: (context, index) {
                  final site = sites[index];
                  return ListTile(
                    title: Text(site['siteName']),
                    subtitle: Text(site['mgrs']),
                    trailing: IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: () => _manageTargets(site),
                    ),
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
