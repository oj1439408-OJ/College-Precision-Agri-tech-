import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _farmerName = 'Ramesh Patel';
  String _farmName = 'Greenfield Farm #1';
  String _selectedLanguage = 'English';
  bool _notifications = true;
  bool _autoIrrigation = true;
  bool _isDemoMode = ApiService.isOfflineDemoMode;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiService.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farmer Profile Section
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2E7D32),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(_farmerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Farm: $_farmName'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _showEditProfileDialog,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Preferences & Language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language, color: Color(0xFF2E7D32)),
                    title: const Text('App Language'),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      underline: const SizedBox(),
                      items: ['English', 'Hindi', 'Marathi'].map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLanguage = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF2E7D32)),
                    title: const Text('Push Notifications'),
                    value: _notifications,
                    activeTrackColor: const Color(0xFF2E7D32),
                    onChanged: (val) => setState(() => _notifications = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.water_drop_outlined, color: Color(0xFF2E7D32)),
                    title: const Text('Auto Irrigation Default'),
                    value: _autoIrrigation,
                    activeTrackColor: const Color(0xFF2E7D32),
                    onChanged: (val) => setState(() => _autoIrrigation = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Flask API & ESP32 Backend Connection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Demo / Offline Mode'),
                      subtitle: const Text('Uses realistic mock data when Flask server is offline'),
                      value: _isDemoMode,
                      activeTrackColor: const Color(0xFF2E7D32),
                      onChanged: (val) {
                        setState(() {
                          _isDemoMode = val;
                          ApiService.isOfflineDemoMode = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _urlController,
                      enabled: !_isDemoMode,
                      decoration: InputDecoration(
                        labelText: 'Flask REST API Base URL',
                        hintText: 'http://192.168.1.100:5000/api',
                        filled: true,
                        fillColor: const Color(0xFFF4F7F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        ApiService.baseUrl = val;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'About Application',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Precision Agri-Tech: AI-Powered Smart Soil & Crop Management System',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 6),
                    Text('Version: 1.0.0 (BSc IT College Demonstration Prototype)'),
                    SizedBox(height: 4),
                    Text(
                      'Architecture: ESP32 Sensors → Wi-Fi → Flask API → MySQL → Flutter App',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _farmerName);
    final farmCtrl = TextEditingController(text: _farmName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Farmer Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Farmer Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: farmCtrl,
                decoration: const InputDecoration(labelText: 'Farm Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _farmerName = nameCtrl.text;
                  _farmName = farmCtrl.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
