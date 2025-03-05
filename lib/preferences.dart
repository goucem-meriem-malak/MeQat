import 'package:flutter/material.dart';
import 'package:meqattest/Other.dart';
import 'package:meqattest/login.dart';
import 'package:meqattest/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

final other = Other();
final Color buttonColor = Color(0xFFE5C99F);
final Color textColor = Color(0xC52E2E2E);

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {

  String? selectedLanguage = "English";
  String? selectedGoal = "Umrah";
  String? selectedMadhhab;
  String? selectedCountry;
  String? selectedTransportation;
  bool isWithDelegation = false;

  final List<String> languages = other.languages;
  final List<String> goal = other.goal;
  final List<String> madhhabs = other.madhhabs;
  final List<String> countries = other.countries;
  final List<String> transportationMethods = other.transportationMethods;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('language') ?? "English";
      selectedGoal = goal.contains(prefs.getString('goal')) ? prefs.getString('goal') : goal[0];
      selectedMadhhab = madhhabs.contains(prefs.getString('madhhab')) ? prefs.getString('madhhab') : null;
      selectedCountry = countries.contains(prefs.getString('country')) ? prefs.getString('country') : null;
      selectedTransportation = transportationMethods.contains(prefs.getString('transportation')) ? prefs.getString('transportation') : null;
      isWithDelegation = prefs.getBool('delegation') ?? false;
    });
  }

  _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', selectedLanguage ?? "English");
    prefs.setString('goal', selectedGoal ?? "");
    prefs.setString('madhhab', selectedMadhhab ?? "");
    prefs.setString('country', selectedCountry ?? "");
    prefs.setString('transportation', selectedTransportation ?? "");
    prefs.setBool('delegation', isWithDelegation);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(),
      ),
    );
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

            // Hajj/Umrah Switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hajj", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Switch(
                    value: selectedGoal == "Umrah",
                    activeColor: Colors.black,
                    onChanged: (bool value) {
                      setState(() {
                        selectedGoal = value ? "Umrah" : "Hajj";
                      });
                    },
                  ),
                  const Text("Umrah", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dropdowns
            _buildDropdown("Choose Madhhab", Icons.school, madhhabs),
            const SizedBox(height: 16),
            _buildDropdown("Choose Country", Icons.location_on, countries),
            const SizedBox(height: 16),
            _buildDropdown("Choose Transportation", Icons.directions, transportationMethods),

            const SizedBox(height: 24),

            // Delegation Checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Checkbox(
                    value: isWithDelegation,
                    onChanged: (value) {
                      setState(() {
                        isWithDelegation = value!;
                      });
                    },
                    activeColor: Colors.black,
                  ),
                  const Text("Traveling with a Delegation", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),

            const Spacer(),

            // Log In Button (Clickable Text)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  "Log In",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

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
              onPressed: () {
                _savePreferences();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpPage(),
                  ),
                );
              },
              child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),

            const SizedBox(height: 40),

            const Text("MeQat", style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, IconData icon, List<String> listItems) {
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
        onChanged: (value) {
          print("Selected: $value"); // Handle selection here
        },
      ),
    );
  }
}