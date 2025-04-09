import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import '../translations.dart';
import 'main_menu_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? currentUser;
  final String language;

  const UserProfileScreen({
    super.key,
    required this.isEditing,
    this.currentUser,
    required this.language,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  late String userId;
  String fullName = '';
  String role = 'Trainee';
  String meterModel = '1.0 STEREOETMIT R 36 A';
  String unit = '';
  String section = '';
  String serialNumber = '';

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.currentUser != null) {
      final user = widget.currentUser!;
      userId = user['userId'];
      fullName = user['fullName'];
      role = user['role'];
      meterModel = user['meterModel'] ?? meterModel;
      unit = user['unit'] ?? '';
      section = user['section'] ?? '';
      serialNumber = user['serialNumber'] ?? '';
    } else {
      userId = _uuid.v4();
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final newUser = {
        'userId': userId,
        'fullName': fullName,
        'role': role,
        'meterModel': meterModel,
        'unit': unit,
        'section': section,
        'serialNumber': serialNumber,
      };

      final users = prefs.getStringList('users') ?? [];
      users.removeWhere((u) => jsonDecode(u)['userId'] == userId);
      users.add(jsonEncode(newUser));
      await prefs.setStringList('users', users);
      await prefs.setString('currentUser', jsonEncode(newUser));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenuScreen(
            currentUser: newUser,
            onSwitchUser: () => Navigator.pop(context),
            onChangeLanguage: (_) {},
            language: widget.language,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing
            ? translated('edit_profile', widget.language)
            : translated('create_new_user', widget.language)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: fullName,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onChanged: (value) => fullName = value,
                ),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'Trainee', child: Text('Trainee')),
                    DropdownMenuItem(value: 'Instructor', child: Text('Instructor')),
                  ],
                  onChanged: (value) => setState(() => role = value!),
                ),
                TextFormField(
                  initialValue: meterModel,
                  decoration: const InputDecoration(labelText: 'Meter Model'),
                  onChanged: (value) => meterModel = value,
                ),
                TextFormField(
                  initialValue: unit,
                  decoration: const InputDecoration(labelText: 'Unit (Optional)'),
                  onChanged: (value) => unit = value,
                ),
                TextFormField(
                  initialValue: section,
                  decoration: const InputDecoration(labelText: 'Section (Optional)'),
                  onChanged: (value) => section = value,
                ),
                TextFormField(
                  initialValue: serialNumber,
                  decoration: const InputDecoration(labelText: 'Serial Number (Optional)'),
                  onChanged: (value) => serialNumber = value,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text(widget.isEditing
                      ? translated('edit_profile', widget.language)
                      : translated('create_new_user', widget.language)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
