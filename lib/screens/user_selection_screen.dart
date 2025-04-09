import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'user_profile_screen.dart';
import '../translations.dart';

class UserSelectionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onUserSelected;
  final Function(String) onLanguageSelected;
  final String language;

  const UserSelectionScreen({
    super.key,
    required this.onUserSelected,
    required this.onLanguageSelected,
    required this.language,
  });

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final userList = prefs.getStringList('users') ?? [];
    setState(() {
      users = userList.map((u) => jsonDecode(u) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _createNewUser() async {
    final newUser = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          isEditing: false,
          language: widget.language,
        ),
      ),
    );
    if (newUser != null) {
      widget.onUserSelected(newUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translated('select_user', widget.language))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: widget.language,
              onChanged: (value) {
                if (value != null) {
                  widget.onLanguageSelected(value);
                }
              },
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fi', child: Text('Suomi')),
                DropdownMenuItem(value: 'sv', child: Text('Svenska')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: users.isNotEmpty
                  ? ListView(
                      children: users.map((user) {
                        return ListTile(
                          title: Text(user['fullName']),
                          subtitle: Text(user['role']),
                          onTap: () => widget.onUserSelected(user),
                        );
                      }).toList(),
                    )
                  : Center(
                      child: Text(translated('create_new_user', widget.language)),
                    ),
            ),
            ElevatedButton(
              onPressed: _createNewUser,
              child: Text(translated('create_new_user', widget.language)),
            ),
          ],
        ),
      ),
    );
  }
}
