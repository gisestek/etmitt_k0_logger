import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'screens/main_menu_screen.dart';
import 'screens/user_selection_screen.dart';

void main() {
  runApp(const ETMITTK0LoggerApp());
}

class ETMITTK0LoggerApp extends StatefulWidget {
  const ETMITTK0LoggerApp({super.key});

  @override
  State<ETMITTK0LoggerApp> createState() => _ETMITTK0LoggerAppState();
}

class _ETMITTK0LoggerAppState extends State<ETMITTK0LoggerApp> {
  Map<String, dynamic>? _currentUser;
  String _language = 'en';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    final language = prefs.getString('language') ?? 'en';
    setState(() {
      _currentUser = userJson != null ? jsonDecode(userJson) : null;
      _language = language;
    });
  }

  void _setCurrentUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user));
    setState(() {
      _currentUser = user;
    });
  }

  void _setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _language = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETMITT K0 Logger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _currentUser != null
          ? MainMenuScreen(
              currentUser: _currentUser!,
              onSwitchUser: () => setState(() => _currentUser = null),
              onChangeLanguage: _setLanguage,
              language: _language,
            )
          : UserSelectionScreen(
              onUserSelected: _setCurrentUser,
              onLanguageSelected: _setLanguage,
              language: _language,
            ),
    );
  }
}
