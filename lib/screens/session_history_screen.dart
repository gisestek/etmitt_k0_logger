import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../translations.dart';

class SessionHistoryScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final String language;

  const SessionHistoryScreen({
    super.key,
    required this.currentUser,
    required this.language,
  });

  Future<List<Map<String, dynamic>>> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = currentUser['userId'];
    final sessionStrings = prefs.getStringList('sessions_$userId') ?? [];
    return sessionStrings.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translated('view_session_history', language))),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadSessions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data!;
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions recorded.'));
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                title: Text('Session ${index + 1}'),
                subtitle: Text(
                  'Date: ${session['timestamp']}\nStd Dev: ${session['stdDev']?.toStringAsFixed(2) ?? 'N/A'}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
