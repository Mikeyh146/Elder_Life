import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = true;

  @override
  void initState() {
    super.initState();
    // Load settings from storage if needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: darkMode,
            onChanged: (value) {
              setState(() {
                darkMode = value;
                // You could update the app's theme and save the preference.
              });
            },
          ),
          // Add more settings as needed.
          const ListTile(
            title: Text("Other setting"),
            subtitle: Text("Description"),
          ),
        ],
      ),
    );
  }
}
