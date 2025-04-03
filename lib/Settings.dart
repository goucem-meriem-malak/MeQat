import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meqat/login.dart';
import 'home.dart';
import 'dart:io';

import 'menu.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? language;
  String? madhhab;
  String? country;
  String? transportation;
  bool? isWithDelegation;
  bool? isHajjOrUmrah;
  String? firstName;
  String? lastName;
  String? imageUrl;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language');
      madhhab = prefs.getString('madhhab');
      country = prefs.getString('country');
      transportation = prefs.getString('transportation');
      isWithDelegation = prefs.getBool('isMember');
      isHajjOrUmrah = prefs.getBool('isHajjOrUmrah');
      firstName = prefs.getString('firstName');
      lastName = prefs.getString('lastName');
      imageUrl = prefs.getString('face_image');
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language ?? '');
    await prefs.setString('madhhab', madhhab ?? '');
    await prefs.setString('country', country ?? '');
    await prefs.setString('transportation', transportation ?? '');
    await prefs.setBool('isMember', isWithDelegation ?? false);
    await prefs.setBool('isHajjOrUmrah', isHajjOrUmrah ?? false);
    await prefs.setString('firstName', firstName ?? '');
    await prefs.setString('lastName', lastName ?? '');
    await prefs.setString('face_image', imageUrl ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 50) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.red),
              onPressed: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                    ? (imageUrl!.startsWith('http')
                    ? NetworkImage(imageUrl!)
                    : FileImage(File(imageUrl!))) as ImageProvider
                    : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              const SizedBox(height: 10),
              Text(
                '${firstName ?? ''} ${lastName ?? ''}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildToggleItem('Hajj/Umrah', isHajjOrUmrah),
                    _buildSettingItem('Language', language),
                    _buildSettingItem('Madhhab', madhhab),
                    _buildSettingItem('Country', country),
                    _buildSettingItem('Transportation', transportation),
                    _buildToggleItem('With Delegation', isWithDelegation),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _savePreferences();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Settings saved successfully!')),
            );
          },
          child: Icon(Icons.save),
        ),
        bottomNavigationBar: SizedBox(
          height: 60,
          child: BottomAppBar(
            color: Colors.white,
            elevation: 10,
            shadowColor: Colors.grey.shade400,
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.workspace_premium),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(String label, String? value) {
    return ListTile(
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(value ?? 'Not Set', style: TextStyle(color: Colors.grey)),
      trailing: isEditing ? Icon(Icons.edit, color: Colors.grey.shade600) : null,
      onTap: () {
        if (isEditing) {
          _showEditDialog(label);
        }
      },
    );
  }

  Widget _buildToggleItem(String label, bool? value) {
    return SwitchListTile(
      title: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      value: value ?? false,
      onChanged: isEditing
          ? (bool newValue) {
        setState(() {
          if (label == 'With Delegation') {
            isWithDelegation = newValue;
          } else if (label == 'Hajj/Umrah') {
            isHajjOrUmrah = newValue;
          }
        });
      }
          : null,
    );
  }

  Future<void> _showEditDialog(String field) async {
    TextEditingController controller = TextEditingController();
    switch (field) {
      case 'Language':
        controller.text = language ?? '';
        break;
      case 'Madhhab':
        controller.text = madhhab ?? '';
        break;
      case 'Country':
        controller.text = country ?? '';
        break;
      case 'Transportation':
        controller.text = transportation ?? '';
        break;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                setState(() {
                  switch (field) {
                    case 'Language':
                      language = controller.text;
                      break;
                    case 'Madhhab':
                      madhhab = controller.text;
                      break;
                    case 'Country':
                      country = controller.text;
                      break;
                    case 'Transportation':
                      transportation = controller.text;
                      break;
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

}
