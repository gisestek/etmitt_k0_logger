import 'package:flutter/material.dart';
import '../translations.dart';
import 'user_profile_screen.dart';
import 'new_session_screen.dart';
import 'session_history_screen.dart';
import 'site_management_screen.dart';
import '../utils/csv_export.dart';

class MainMenuScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final Function() onSwitchUser;
  final Function(String) onChangeLanguage;
  final String language;

  const MainMenuScreen({
    super.key,
    required this.currentUser,
    required this.onSwitchUser,
    required this.onChangeLanguage,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ETMITT Logger for ${currentUser['fullName']}'),
        actions: [
          DropdownButton<String>(
            value: language,
            underline: Container(),
            icon: const Icon(Icons.language, color: Colors.white),
            onChanged: (value) {
              if (value != null) {
                onChangeLanguage(value);
              }
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('EN')),
              DropdownMenuItem(value: 'fi', child: Text('FI')),
              DropdownMenuItem(value: 'sv', child: Text('SV')),
            ],
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewSessionScreen(
                        currentUser: currentUser,
                        language: language,
                      ),
                    ),
                  );
                },
                child: Text(translated('new_training_session', language)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(
                        isEditing: true,
                        currentUser: currentUser,
                        language: language,
                      ),
                    ),
                  );
                },
                child: Text(translated('edit_profile', language)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionHistoryScreen(
                        currentUser: currentUser,
                        language: language,
                      ),
                    ),
                  );
                },
                child: Text(translated('view_session_history', language)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SiteManagementScreen(
                        language: language,
                      ),
                    ),
                  );
                },
                child: Text(translated('manage_sites_targets', language)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => exportToCsv(currentUser),
                child: Text(translated('export_csv', language)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onSwitchUser,
                child: Text(translated('switch_user', language)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
