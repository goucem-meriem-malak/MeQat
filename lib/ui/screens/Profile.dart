import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/local/shared_pref.dart';
import '../../data/models/preference.dart';
import '../../data/models/user.dart';
import '../../data/services/data_provider.dart';
import '../../data/services/firebase_service.dart';
import '../../main.dart';
import '../helpers/ui_functions.dart';
import 'premium.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? language, madhhab, country, transportation;
  bool? delegation, goal, leader;
  String? firstName, lastName, imageUrl;
  bool isEditing = false;
  String? _currentlyEditingLabel;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadImageFromPrefs();
  }

  Future<void> _loadPreferences() async {
    myUser? user = await SharedPref().getUser();
    Preference pref = await SharedPref().getPreferences();
    String languge = await SharedPref().getLanguage();
    String? img = await SharedPref().getImg();
    if(languge.isEmpty || languge == null){
      languge = 'en';
    }
    setState(() {
      language = languge;
      madhhab = pref.maddhab;
      country = pref.country;
      transportation = pref.transportation;
      delegation = pref.delegation;
      goal = pref.goal;
      leader = pref.leader;
      firstName = user!.firstName;
      lastName = user.lastName;
      imageUrl = img;
    });
  }

  Future<void> _savePreferences() async {
    await SharedPref().saveLanguage(language ?? 'en');
    await SharedPref().savePreference('madhhab', madhhab);
    await SharedPref().savePreference('country', country);
    await SharedPref().savePreference('transportation', transportation);
    await SharedPref().savePreference('leader', leader);
    await SharedPref().savePreference('goal', goal);
    await SharedPref().savePreference('delegation', delegation);
    await SharedPref().updateUserName(firstName!, lastName!);
  }

  Future<void> _loadImageFromPrefs() async {
    final String? imagePath = await SharedPref().getImg();
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        _imageFile = File(imagePath);
        imageUrl = imagePath;
      });
    }
  }

  Future<void> _saveImageToPrefs(File imageFile) async {
    File savedImage = await SharedPref().saveImg(imageFile);
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
      await UpdateFirebase().uploadPicSupbase(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> languages = Other.languages(context);
    final List<String> madhhabs = Other.madhhabs(context);
    final List<String> countries = Other.countries(context);
    final List<String> transportations = Other.transportationMethods(context);
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 50) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PremiumPage()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app_rounded, color: Colors.deepPurple),
              onPressed: () async {
                SharedPref().clearAll();
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
                      SnackBar(content: Text(AppLocalizations.of(context)!.edit_info)),
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
                      SnackBar(content: Text(AppLocalizations.of(context)!.edit_info)),
                    );
                    }
                },
                child: Text(
                  ((firstName?.isEmpty ?? true) && (lastName?.isEmpty ?? true))
                      ? AppLocalizations.of(context)!.enter_name
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
                    AppLocalizations.of(context)!.edit_info,
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
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.hajj, textAlign: TextAlign.end),
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
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.umrah, textAlign: TextAlign.start),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.individual, textAlign: TextAlign.end),
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
                              Expanded(
                                child: Text(AppLocalizations.of(context)!.delegation, textAlign: TextAlign.start),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (delegation ?? false)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Text(AppLocalizations.of(context)!.member, textAlign: TextAlign.end),
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
                                Expanded(
                                  child: Text(AppLocalizations.of(context)!.leader, textAlign: TextAlign.start),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    _buildSettingItem(AppLocalizations.of(context)!.language, language, languages),
                    _buildSettingItem(AppLocalizations.of(context)!.madhhab, madhhab, madhhabs),
                    _buildSettingItem(AppLocalizations.of(context)!.country, country, countries),
                    _buildSettingItem(AppLocalizations.of(context)!.transportation, transportation, transportations),
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
              SnackBar(content: Text(AppLocalizations.of(context)!.saved)),
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

  Widget _buildSettingItem(String label, String? value, List<String> list) {
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
        (value == null || value.isEmpty) ? AppLocalizations.of(context)!. not_set : value,
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

          await _showEditDialog(label, list);


          setState(() {
            _currentlyEditingLabel = null;
          });
        }
      },
    );
  }

  Future<void> _showEditDialog(String label, List<String> list) async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        // ✅ Now context is properly localized!
        List<String> options = [];

        options = list;

        return SimpleDialog(
          title: Text(
            AppLocalizations.of(context)!.select_label(label),
          ),
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
      setState(() async {
        switch (label) {
          case 'Language':
            language = selected;
            final langCode = selected == 'Arabic' ? 'ar' : 'en';
            await SharedPref().saveLanguage(langCode);
            MyApp.setLocale(context, Locale(langCode));
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
          title: Text(AppLocalizations.of(context)!.enter_name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fname),
                onChanged: (val) => newFirstName = val,
                controller: TextEditingController(text: firstName),
              ),
              TextField(
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lname),
                onChanged: (val) => newLastName = val,
                controller: TextEditingController(text: lastName),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  firstName = newFirstName;
                  lastName = newLastName;
                });
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
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
              title: Text(AppLocalizations.of(context)!.take_pic),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text(AppLocalizations.of(context)!.pick_gallery),
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
