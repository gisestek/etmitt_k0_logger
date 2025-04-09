import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(ETMITTK0LoggerApp());

class ETMITTK0LoggerApp extends StatefulWidget {
  @override
  State<ETMITTK0LoggerApp> createState() => _ETMITTK0LoggerAppState();
}

class _ETMITTK0LoggerAppState extends State<ETMITTK0LoggerApp> {
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isProfileComplete = prefs.getString('fullName') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETMITT K0 Logger',
      home: _isProfileComplete ? MainMenuScreen() : UserProfileScreen(),
    );
  }
}

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  String fullName = '';
  String role = 'Trainee';
  String meterModel = '1.0 STEREOETMIT R 36 A';
  String unit = '';
  String section = '';
  String serialNumber = '';

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _uuid.v4());
      await prefs.setString('fullName', fullName);
      await prefs.setString('role', role);
      await prefs.setString('meterModel', meterModel);
      await prefs.setString('unit', unit);
      await prefs.setString('section', section);
      await prefs.setString('serialNumber', serialNumber);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainMenuScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
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
                  decoration: InputDecoration(labelText: 'Meter Model'),
                  initialValue: meterModel,
                  onChanged: (value) => meterModel = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Unit (Optional)'),
                  onChanged: (value) => unit = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Section (Optional)'),
                  onChanged: (value) => section = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Serial Number (Optional)'),
                  onChanged: (value) => serialNumber = value,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ETMITT Logger')),
      body: Center(child: Text('Main Menu - More features coming soon')), // Placeholder
    );
  }
}
