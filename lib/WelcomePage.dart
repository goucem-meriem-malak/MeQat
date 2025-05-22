import 'package:flutter/material.dart';
import 'package:meqat/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Color buttonColor = Color(0xFFE5C99F);
final Color fontColor = Color(0xC52E2E2E);

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String _selectedLanguage = "English";

  Future<void> _saveLanguageAndProceed() async {
    final languageCodes = {
      'English': 'en',
      'French': 'fr',
      'Arabic': 'ar',
    };

    final code = languageCodes[_selectedLanguage] ?? 'en';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SignUpPage()),
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

            _buildLanguageSelector(),

            const Spacer(flex: 2),

            Center(child: Image.asset('assets/icon/img5.png', width: 120)),

            const Spacer(flex: 2),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.withOpacity(0.6),
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
                      builder: (context) => SignUpPage(),
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
          items: ["English", "Arabic"]
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