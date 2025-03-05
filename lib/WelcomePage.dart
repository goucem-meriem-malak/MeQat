import 'package:flutter/material.dart';
import 'package:meqattest/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Color buttonColor = Color(0xFFE5C99F);
final Color fontColor = Color(0xC52E2E2E);

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String _selectedLanguage = "English"; // Default choice

  Future<void> _saveLanguageAndProceed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PreferencesPage()), // Go to preferences
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 80),

            // Language picker
            _buildLanguageSelector(),

            const Spacer(flex: 2), // Pushes logo to center

            // Logo centered in the screen
            Center(child: Image.asset('assets/logo.png', width: 120)),

            const Spacer(flex: 2),

            // Continue button with proper padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  _saveLanguageAndProceed();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreferencesPage(),
                    ),
                  );
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 1),

            Column(
              children: [
                const SizedBox(height: 10),
                const Text("MeQat", style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          icon: Icon(Icons.arrow_drop_down, color: fontColor),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLanguage = newValue!;
            });
          },
          items: ["English", "Arabic", "French"]
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    _selectedLanguage == value ? Icons.check_circle : Icons.circle_outlined,
                    color: _selectedLanguage == value ? buttonColor : Colors.grey,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedLanguage == value ? fontColor : Colors.grey.shade700,
                      fontWeight: _selectedLanguage == value ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}