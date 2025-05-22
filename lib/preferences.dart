import 'package:flutter/material.dart';
import 'package:meqat/Data.dart';
import 'package:meqat/firebase.dart';
import 'package:meqat/home.dart';
import 'package:meqat/login.dart';
import 'QRPage.dart';
import 'sharedPref.dart';

final other = Other();

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}


class _PreferencesPageState extends State<PreferencesPage> {
  String? uid;

  String? selectedLanguage;
  bool selectedGoal = false;
  String? selectedMadhhab;
  String? selectedCountry;
  String? selectedTransportation;
  bool _isWithDelegation = false;
  bool _isLeader = false;

  final List<String> languages = Other.languages;
  final List<String> goal = Other.goal;
  final List<String> madhhabs = Other.madhhabs;
  final List<String> countries = Other.countries;
  final List<String> transportationMethods = Other.transportationMethods;

  @override
  void initState(){
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
        child: Column(
          children: [
            const Spacer(flex: 5),

            Center(
              child: Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF353535), // Softer than black
                  letterSpacing: 1.4,
                  shadows: [
                    Shadow(
                      offset: Offset(0.5, 1.5),
                      blurRadius: 4.0,
                      color: Colors.black12,
                    ),
                    Shadow(
                      offset: Offset(-0.5, -0.5),
                      blurRadius: 2.0,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 26),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text("Hajj", textAlign: TextAlign.end),
                      ),
                      Switch(
                        value: selectedGoal,
                        activeColor: Colors.deepPurpleAccent,
                        onChanged: (bool value) {
                          setState(() {
                            selectedGoal = value;
                          });
                        }
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        value: _isWithDelegation,
                        activeColor: Colors.deepPurple,
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


            const SizedBox(height: 16),

            _buildDropdown("Choose Madhhab", Icons.school, madhhabs, (value) {
              setState(() {
                selectedMadhhab = value;
              });
            }),
            const SizedBox(height: 10),
            _buildDropdown("Choose Country", Icons.location_on, countries, (value) {
              setState(() {
                selectedCountry = value;
              });
            }),
            const SizedBox(height: 10),
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
                backgroundColor: Colors.deepPurple.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                SharedPref().savePreference("goal", goal);
                SharedPref().savePreference("delegation", _isWithDelegation);
                SharedPref().savePreference("leader", _isLeader);
                SharedPref().savePreference("madhhab", selectedMadhhab);
                SharedPref().savePreference("country", selectedCountry);
                SharedPref().savePreference("transportation", selectedTransportation);

                final userData = {
                  'goal': selectedGoal,
                  'madhhab': selectedMadhhab,
                  'country': selectedCountry,
                  'transportation': selectedTransportation,
                  'delegation': _isWithDelegation,
                  'leader': _isLeader,
                };
                await UpdateFirebase().uploadPreferences(userData);

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
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
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

  Widget _buildDropdown(
      String hint, IconData icon, List<String> listItems, Function(String?) onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0,0),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54, size: 20),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.deepPurple, size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
          ),
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        hint: Text(hint, style: const TextStyle(color: Colors.grey)),
        items: listItems.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(item),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _loadData() async {
  uid = await SharedPref().getUID();
  selectedLanguage = await SharedPref().getPreference("language");

  setState(() {}); // Refresh UI after values are loaded
  }
}