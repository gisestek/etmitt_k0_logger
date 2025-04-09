import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:html' as html;

Future<void> exportToCsv(Map<String, dynamic> currentUser) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = currentUser['userId'];
  final sessions = prefs.getStringList('sessions_$userId') ?? [];

  final rows = [
    ['Timestamp', 'Values', 'Standard Deviation'],
    ...sessions.map((session) {
      final data = jsonDecode(session);
      return [
        data['timestamp'],
        (data['values'] as List<dynamic>).join(' '),
        data['stdDev'].toString()
      ];
    }),
  ];

  final csvContent = rows.map((row) => row.map((e) => '"$e"').join(',')).join('\n');
  final blob = html.Blob([csvContent], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = 'k0_sessions_${currentUser['fullName'].replaceAll(' ', '_')}.csv';

  html.document.body!.children.add(anchor);
  anchor.click();

  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
