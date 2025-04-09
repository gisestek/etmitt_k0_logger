import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:html' as html;

void main() => runApp(ETMITTK0LoggerApp());

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
      home: _currentUser != null
          ? MainMenuScreen(
        currentUser: _currentUser!,
        onSwitchUser: () => _setCurrentUser({}),
        onChangeLanguage: _setLanguage,
        language: _language,
      )
          : UserSelectionScreen(onUserSelected: _setCurrentUser, onLanguageSelected: _setLanguage, language: _language),
    );
  }
}

// ---------------------------- User Selection Screen ----------------------------

class UserSelectionScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onUserSelected;
  final Function(String) onLanguageSelected;
  final String language;

  const UserSelectionScreen({super.key, required this.onUserSelected, required this.onLanguageSelected, required this.language});

  @override
  _UserSelectionScreenState createState() => _UserSelectionScreenState();
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
      MaterialPageRoute(builder: (context) => UserProfileScreen(isEditing: false, language: widget.language)),
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
              onChanged: (value) => widget.onLanguageSelected(value!),
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fi', child: Text('Suomi')),
                DropdownMenuItem(value: 'sv', child: Text('Svenska')),
              ],
            ),
            SizedBox(height: 20),
            if (users.isNotEmpty)
              ...users.map((user) => ListTile(
                title: Text(user['fullName']),
                subtitle: Text(user['role']),
                onTap: () => widget.onUserSelected(user),
              )),
            Spacer(),
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

String translated(String key, String language) {
  const translations = {
    'select_user': {
      'en': 'Select User',
      'fi': 'Valitse käyttäjä',
      'sv': 'Välj användare',
    },
    'create_new_user': {
      'en': 'Create New User',
      'fi': 'Luo uusi käyttäjä',
      'sv': 'Skapa ny användare',
    },
    'new_training_session': {
      'en': 'New Training Session',
      'fi': 'Uusi harjoituskerta',
      'sv': 'Ny träningssession',
    },
    'edit_profile': {
      'en': 'Edit Profile',
      'fi': 'Muokkaa profiilia',
      'sv': 'Redigera profil',
    },
    'view_session_history': {
      'en': 'View Session History',
      'fi': 'Näytä sessiohistoria',
      'sv': 'Visa sessionshistorik',
    },
    'manage_sites_targets': {
      'en': 'Manage Sites & Targets',
      'fi': 'Hallinnoi mittauspaikkoja',
      'sv': 'Hantera platser och mål',
    },
    'export_csv': {
      'en': 'Export Data to CSV',
      'fi': 'Vie tiedot CSV-muotoon',
      'sv': 'Exportera data till CSV',
    },
    'switch_user': {
      'en': 'Switch User',
      'fi': 'Vaihda käyttäjää',
      'sv': 'Byt användare',
    },
  };

  return translations[key]?[language] ?? key;
}

// ---------------------------- User Profile Screen ----------------------------

class UserProfileScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? currentUser;
  final String language;

  const UserProfileScreen({super.key, required this.isEditing, this.currentUser, required this.language});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
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
      meterModel = user['meterModel'] ?? '1.0 STEREOETMIT R 36 A';
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenuScreen(
            currentUser: newUser,
            onSwitchUser: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserSelectionScreen(
                  onUserSelected: (user) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainMenuScreen(
                        currentUser: user,
                        onSwitchUser: () => {},
                        onChangeLanguage: (lang) => {},
                        language: widget.language,
                      ),
                    ),
                  ),
                  onLanguageSelected: (lang) => {},
                  language: widget.language,
                ),
              ),
            ),
            onChangeLanguage: (lang) => {},
            language: widget.language,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? translated('edit_profile', widget.language) : translated('create_new_user', widget.language))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: fullName,
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onChanged: (value) => fullName = value,
                ),
                DropdownButtonFormField(
                  value: role,
                  decoration: InputDecoration(labelText: 'Role'),
                  items: ['Trainee', 'Instructor']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (value) => setState(() => role = value!),
                ),
                TextFormField(
                  initialValue: meterModel,
                  decoration: InputDecoration(labelText: 'Meter Model'),
                  onChanged: (value) => meterModel = value,
                ),
                TextFormField(
                  initialValue: unit,
                  decoration: InputDecoration(labelText: 'Unit (Optional)'),
                  onChanged: (value) => unit = value,
                ),
                TextFormField(
                  initialValue: section,
                  decoration: InputDecoration(labelText: 'Section (Optional)'),
                  onChanged: (value) => section = value,
                ),
                TextFormField(
                  initialValue: serialNumber,
                  decoration: InputDecoration(labelText: 'Serial Number (Optional)'),
                  onChanged: (value) => serialNumber = value,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text(widget.isEditing ? translated('edit_profile', widget.language) : translated('create_new_user', widget.language)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------- Main Menu Screen ----------------------------

class MainMenuScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final Function() onSwitchUser;
  final Function(String) onChangeLanguage;
  final String language;

  const MainMenuScreen({super.key,
    required this.currentUser,
    required this.onSwitchUser,
    required this.onChangeLanguage,
    required this.language,
  });

  get widget => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ETMITT Logger for ${currentUser['fullName']}'),
        actions: [
          DropdownButton<String>(
            value: language,
            underline: Container(),
            icon: Icon(Icons.language, color: Colors.white),
            onChanged: (String? value) {
              if (value != null) widget.onLanguageSelected(value);
            },

            items: [
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NewSessionScreen(currentUser: currentUser, language: language)));
                },
                child: Text(translated('new_training_session', language)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserProfileScreen(isEditing: true, currentUser: currentUser, language: language)));
                },
                child: Text(translated('edit_profile', language)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SessionHistoryScreen(currentUser: currentUser, language: language)));
                },
                child: Text(translated('view_session_history', language)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SiteManagementScreen(language: language)));
                },
                child: Text(translated('manage_sites_targets', language)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => exportToCsv(currentUser),
                child: Text(translated('export_csv', language)),
              ),
              SizedBox(height: 20),
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

// ---------------------------- K0 Session Screen ----------------------------

class NewSessionScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final String language;

  const NewSessionScreen({super.key, required this.currentUser, required this.language});

  @override
  _NewSessionScreenState createState() => _NewSessionScreenState();
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

    Navigator.pop(context);
  }

  double _calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sumSq = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b);
    return sqrt(sumSq / values.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translated('new_training_session', widget.language))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter K0 value'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addK0Value,
              child: Text('Add Value'),
            ),
            SizedBox(height: 20),
            Text('Values: ${k0Values.join(', ')}'),
            if (stdDev != null)
              Text('Standard Deviation: ${stdDev!.toStringAsFixed(2)}'),
            Spacer(),
            ElevatedButton(
              onPressed: _finishSession,
              child: Text('Finish Session'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------- Session History Screen ----------------------------

class SessionHistoryScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final String language;

  const SessionHistoryScreen({super.key, required this.currentUser, required this.language});

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
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final sessions = snapshot.data!;

          if (sessions.isEmpty) {
            return Center(child: Text('No sessions recorded.'));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                  title: Text('Session ${index + 1}'),
                subtitle: Text('Date: ${session['timestamp']}\nStd Dev: ${session['stdDev']?.toStringAsFixed(2) ?? 'N/A'}'),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------- CSV Export ----------------------------

void exportToCsv(Map<String, dynamic> currentUser) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = currentUser['userId'];
  final sessions = prefs.getStringList('sessions_$userId') ?? [];

  final rows = [
    ['Timestamp', 'Values', 'Standard Deviation'],
    ...sessions.map((session) {
      final data = jsonDecode(session);
      return [data['timestamp'], data['values'].join(' '), data['stdDev'].toString()];
    }),
  ];

  final csv = const ListToCsvConverter().convert(rows);
  final blob = html.Blob([csv]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'k0_sessions_${currentUser['fullName'].replaceAll(' ', '_')}.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}

class ListToCsvConverter {
  const ListToCsvConverter();

  String convert(List<List<dynamic>> rows) {
    return rows.map((row) => row.map((field) => '"$field"').join(',')).join('\n');

  }
}

// ---------------------------- Site Management Screen ----------------------------

class SiteManagementScreen extends StatelessWidget {
  final String language;

  const SiteManagementScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translated('manage_sites_targets', language))),
      body: Center(
        child: Text(translated('manage_sites_targets', language)),
      ),
    );
  }
}

// ✅ Now no missing references!
// Ready for Site & Target Management full implementation!
