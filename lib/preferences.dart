import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meqat/Data.dart';
import 'package:meqat/home.dart';
import 'package:meqat/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'QRPage.dart';
import 'firebase_options.dart';

final other = Other();
final Color buttonColor = Color(0xFFE5C99F);
final Color textColor = Color(0xC52E2E2E);

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}


class _PreferencesPageState extends State<PreferencesPage> {
  late SharedPreferences prefs;

  String uid = "";
  String? selectedLanguage = "English";
  String? selectedGoal = "Umrah";
  String? selectedMadhhab;
  String? selectedCountry;
  String? selectedTransportation;
  bool _isWithDelegation = false;
  bool _isLeader = false;

  final List<String> languages = other.languages;
  final List<String> goal = other.goal;
  final List<String> madhhabs = other.madhhabs;
  final List<String> countries = other.countries;
  final List<String> transportationMethods = other.transportationMethods;

  @override
  void initState() {
    super.initState();
    getUidFromSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Logo
            Center(
              child: Image.asset("assets/logo.png", width: 80, height: 80, fit: BoxFit.contain),
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        value: selectedGoal == "Umrah",
                        activeColor: Colors.black,
                        onChanged: (bool value) {
                          setState(() {
                            selectedGoal = value ? "Umrah" : "Hajj";
                          });
                        },
                      ),
                      const Expanded(
                        child: Text("Umrah", textAlign: TextAlign.start),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Expanded(
                        child: Text("Individual", textAlign: TextAlign.end),
                      ),
                      Switch(
                        value: _isWithDelegation,
                        activeColor: Colors.purple,
                        onChanged: (value) {
                          setState(() {
                            _isWithDelegation = value;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text("Deligation", textAlign: TextAlign.start),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isWithDelegation)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Expanded(
                          child: Text("Member", textAlign: TextAlign.end),
                        ),
                        Switch(
                          value: _isLeader,
                          activeColor: Colors.purple,
                          onChanged: (value) {
                            setState(() {
                              _isLeader = value;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text("Leader", textAlign: TextAlign.start),
                        ),
                      ],
                    ),
                ],
              ),
            ),


            const SizedBox(height: 24),

            _buildDropdown("Choose Madhhab", Icons.school, madhhabs, (value) {
              setState(() {
                selectedMadhhab = value;
              });
            }),
            const SizedBox(height: 16),
            _buildDropdown("Choose Country", Icons.location_on, countries, (value) {
              setState(() {
                selectedCountry = value;
              });
            }),
            const SizedBox(height: 16),
            _buildDropdown("Choose Transportation", Icons.directions, transportationMethods, (value) {
              setState(() {
                selectedTransportation = value;
              });
            }),
            const Spacer(),

            // Continue Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                saveSharedPreferences();
                if(_isWithDelegation){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRPage(isLeader: _isLeader),
                    ),
                  );
                } else{
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                }
              },
              child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),

            const SizedBox(height: 20),

            const Spacer(flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?", style: TextStyle(color: Colors.black87)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Log in",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "MeQat",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, IconData icon, List<String> listItems, Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        dropdownColor: Colors.white,
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items: listItems.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged, // Use the passed in callback to update the variable
      ),
    );
  }


  Future<String?> getUidFromSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    print('📦 Retrieved UID from SharedPreferences: $uid');
    return uid;
  }


  Future<void> saveSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final userData = {
      'goal': selectedGoal ?? "",
      'madhhab': selectedMadhhab ?? "",
      'country': selectedCountry ?? "",
      'transportation': selectedTransportation ?? "",
      'delegation': _isWithDelegation,
      'leader': _isLeader,
    };

    for (final entry in userData.entries) {
      if (entry.value is String) {
        await prefs.setString(entry.key, entry.value as String);
      } else if (entry.value is bool) {
        await prefs.setBool(entry.key, entry.value as bool);
      }
    }

    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      await prefs.setBool('update', true);
      print("❌ No internet connection.");
      return;
    } else {
      uploadToFirestore(userData);
      await prefs.setBool('update', false);
    }
  }

  Future<void> uploadToFirestore(Map<String, dynamic> userData) async {
    final uid = await getUidFromSharedPref();

    if (uid != null) {
      final dataToUpload = Map<String, dynamic>.from(userData)
        ..putIfAbsent('uid', () => uid); // 👈 add uid inside the data

      await FirebaseFirestore.instance.collection('preferences').doc(uid).set(dataToUpload);
      print('✅ Uploaded to Firestore with UID: $uid');
    } else {
      print("❌ UID not found in SharedPreferences.");
    }
  }



  Future<void> _handlePreferencesUploadAndSave() async {
    try {
      print("🟢 Starting _handlePreferencesUploadAndSave");

      // Ensure Firebase is initialized
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('goal', selectedGoal ?? "");
      prefs.setString('madhhab', selectedMadhhab ?? "");
      prefs.setString('country', selectedCountry ?? "");
      prefs.setString('transportation', selectedTransportation ?? "");
      prefs.setBool('delegation', _isWithDelegation);
      prefs.setBool('leader', _isLeader);

      print("💾 Preferences saved locally");

      // Check internet connectivity
      var connectivityResult = await Connectivity().checkConnectivity();
      bool connected = connectivityResult != ConnectivityResult.none;

      if (!connected) {
        print("📴 No internet connection. Skipping Firebase upload.");
        return;
      }

      print("🌐 Internet available. Proceeding with Firebase upload.");

      String? existingDocId = prefs.getString('meriemmalak');
      DocumentReference docRef;

      if (existingDocId != null) {
        docRef = FirebaseFirestore.instance
            .collection('preferences')
            .doc(existingDocId);
        await docRef.set({
          'language': selectedLanguage,
          'goal': selectedGoal,
          'madhhab': selectedMadhhab,
          'country': selectedCountry,
          'transportation': selectedTransportation,
          'delegation': _isWithDelegation,
          'leader': _isLeader,
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print("🔁 Updated existing preferences with ID: $existingDocId");
      } else {
        docRef = await FirebaseFirestore.instance
            .collection('preferences')
            .add({
          'language': selectedLanguage,
          'goal': selectedGoal,
          'madhhab': selectedMadhhab,
          'country': selectedCountry,
          'transportation': selectedTransportation,
          'delegation': _isWithDelegation,
          'leader': _isLeader,
          'timestamp': FieldValue.serverTimestamp(),
        });

        prefs.setString('meriemmalak', docRef.id);
        print("✅ New preferences uploaded with ID: ${docRef.id}");
      }
    } catch (e) {
      print("❌ Error during preferences upload: $e");
    }
  }


}