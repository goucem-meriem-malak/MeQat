import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meqat/premium.dart';
import 'package:meqat/search.dart';
import 'package:meqat/login.dart';
import 'package:meqat/sharedPref.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Data.dart';
import 'UI.dart';
import 'home.dart';
import 'menu.dart';

class profilePage extends StatefulWidget {
  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  Preference pref = Preference();
  String? language, madhhab, country, transportation;
  bool? delegation, goal, leader;
  String? firstName, lastName, imageUrl;
  bool isEditing = false;
  String? _currentlyEditingLabel;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    loadData();
    _loadPreferences();
    _loadImageFromPrefs();
  }

  Future<void> loadData() async {
    pref = await SharedPref().loadPreferences();
  }


  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language');
      madhhab = prefs.getString('madhhab');
      country = prefs.getString('country');
      transportation = prefs.getString('transportation');
      delegation = prefs.getBool('delegation');
      goal = prefs.getBool('goal');
      leader = prefs.getBool('leader');
      firstName = prefs.getString('firstName');
      lastName = prefs.getString('lastName');
      imageUrl = prefs.getString('face_image');
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('language', language ?? ''),
      prefs.setString('madhhab', madhhab ?? ''),
      prefs.setString('country', country ?? ''),
      prefs.setString('transportation', transportation ?? ''),
      prefs.setBool('leader', leader ?? false),
      prefs.setBool('goal', goal ?? false),
      prefs.setBool('delegation', delegation ?? false),
      prefs.setString('firstName', firstName ?? ''),
      prefs.setString('lastName', lastName ?? ''),
    ]);
  }

  Future<void> _loadImageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('face_image');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _imageFile = File(imagePath);
        imageUrl = imagePath;
      });
    }
  }

  Future<void> _saveImageToPrefs(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    await prefs.setString('face_image', savedImage.path);
    setState(() {
      _imageFile = savedImage;
      imageUrl = savedImage.path;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _imageFile = file;
      });
      await _saveImageToPrefs(file);
    }
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
          title: Text('Profile'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app_rounded, color: Colors.deepPurple),
              onPressed: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_imageFile == null || isEditing) {
                    _showImagePickerOptions();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Click Edit Profile Info")),
                    );
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                  _imageFile != null ? FileImage(_imageFile!) : AssetImage('assets/default_avatar.png') as ImageProvider,
                  child: _imageFile == null
                      ? Icon(Icons.add_a_photo, size: 30, color: Colors.white70)
                      : null,
                ),
              ),
              SizedBox(height: 15),

              GestureDetector(
                onTap: () async {
                  if (isEditing) {
                    await _showEditNameDialog();
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Click Edit Profile Info")),
                    );
                    }
                },
                child: Text(
                  ((firstName?.isEmpty ?? true) && (lastName?.isEmpty ?? true))
                      ? 'Enter your full name'
                      : '${firstName ?? ''} ${lastName ?? ''}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: ((firstName?.isEmpty ?? true) && (lastName?.isEmpty ?? true))
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),

              if (!isEditing)
                TextButton(
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                  child: Text(
                    "Edit profile Info",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.withOpacity(0.6),
                    ),
                  ),
                ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Expanded(
                                child: Text("Hajj", textAlign: TextAlign.end),
                              ),
                              Switch(
                                value: goal ?? false,
                                onChanged: isEditing
                                    ? (bool value) {
                                  setState(() {
                                    goal = value;
                                  });
                                }
                                    : null,
                              ),
                              const Expanded(
                                child: Text("Umrah", textAlign: TextAlign.start),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Expanded(
                                child: Text("Individual", textAlign: TextAlign.end),
                              ),
                              Switch(
                                value: delegation ?? false,
                                activeColor: Colors.deepPurple,
                                onChanged: isEditing
                                    ? (value) {
                                  setState(() {
                                    delegation = value;
                                    if (!value) leader = false;
                                  });
                                }
                                    : null,
                              ),
                              const Expanded(
                                child: Text("Delegation", textAlign: TextAlign.start),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (delegation ?? false)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Expanded(
                                  child: Text("Member", textAlign: TextAlign.end),
                                ),
                                Switch(
                                  value: leader ?? false,
                                  activeColor: Colors.purple,
                                  onChanged: isEditing
                                      ? (value) {
                                    setState(() {
                                      leader = value;
                                    });
                                  }
                                      : null,
                                ),
                                const Expanded(
                                  child: Text("Leader", textAlign: TextAlign.start),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSettingItem('Language', language),
                    _buildSettingItem('Madhhab', madhhab),
                    _buildSettingItem('Country', country),
                    _buildSettingItem('Transportation', transportation),
                  ],
                ),
              ),
              SizedBox(height: 80), // For FAB space
            ],
          ),
        ),


        floatingActionButton: isEditing
            ? FloatingActionButton(
          onPressed: () {
            _savePreferences();
            setState(() {
              isEditing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Settings saved successfully!')),
            );
          },
          child: Icon(Icons.check),
          elevation: 4,
        )
            : null,
        bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 4),
      ),
    );
  }

  Widget _buildSettingItem(String label, String? value) {
    IconData? defaultIcon;

    switch (label) {
      case 'Language':
        defaultIcon = Icons.sort_by_alpha;
        break;
      case 'Madhhab':
        defaultIcon = Icons.menu_book;
        break;
      case 'Country':
        defaultIcon = Icons.public;
        break;
      case 'Transportation':
        defaultIcon = Icons.directions_car;
        break;
    }

    IconData? iconToShow;

    if (isEditing) {
      iconToShow = _currentlyEditingLabel == label ? Icons.edit : defaultIcon;
    } else {
      iconToShow = defaultIcon;
    }

    return ListTile(
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(
        (value == null || value.isEmpty) ? 'Not Set' : value,
        style: TextStyle(color: Colors.grey),
      ),
      trailing: iconToShow != null
          ? Icon(iconToShow, color: Colors.deepPurple.withOpacity(0.6))
          : null,
      onTap: () async {
        if (isEditing) {
          setState(() {
            _currentlyEditingLabel = label;
          });

          await _showEditDialog(label);

          setState(() {
            _currentlyEditingLabel = null;
          });
        }
      },
    );
  }

  Future<void> _showEditDialog(String label) async {
    List<String> options = [];

    switch (label) {
      case 'Language':
        options = Other.languages;
        break;
      case 'Madhhab':
        options = Other.madhhabs;
        break;
      case 'Country':
        options = Other.countries;
        break;
      case 'Transportation':
        options = Other.transportationMethods;
        break;
    }

    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select $label'),
          children: options.map((option) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, option);
              },
              child: Text(option),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      setState(() {
        switch (label) {
          case 'Language':
            language = selected;
            break;
          case 'Madhhab':
            madhhab = selected;
            break;
          case 'Country':
            country = selected;
            break;
          case 'Transportation':
            transportation = selected;
            break;
        }
      });
    }
  }

  Future<void> _showEditNameDialog() async {
    String? newFirstName = firstName;
    String? newLastName = lastName;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter your full name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'First Name'),
                onChanged: (val) => newFirstName = val,
                controller: TextEditingController(text: firstName),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Last Name'),
                onChanged: (val) => newLastName = val,
                controller: TextEditingController(text: lastName),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  firstName = newFirstName;
                  lastName = newLastName;
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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Choose from gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
