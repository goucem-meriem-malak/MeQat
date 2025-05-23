import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meqat/home.dart';
import 'package:meqat/signup.dart';

final Color primaryColor = Color(0xFF2D2D2D);
final Color accentColor = Color(0xFF4A4A4A);
final Color background = Color(0xFFF8F5F0);
final Color buttonColor = Color(0xFFE5C99F);
final Color fontColor = Color(0xC52E2E2E);

class AnimationScreen extends StatefulWidget {
  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> with SingleTickerProviderStateMixin {
  List<bool> _showLetters = [];
  Color _backgroundColor = primaryColor;
  bool _showWelcomeUI = false;
  String _selectedLanguage = "English";

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _showLetters = List<bool>.filled("MeQat".length, false);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _startAnimationSequence();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimationSequence() async {
    for (int i = 0; i < _showLetters.length; i++) {
      await Future.delayed(Duration(milliseconds: 200));
      setState(() {
        _showLetters[i] = true;
      });
    }

    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _backgroundColor = background;
    });

    await Future.delayed(Duration(milliseconds: 800));
    setState(() {
      _showWelcomeUI = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid != null && uid.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      setState(() {
        _showWelcomeUI = true;
      });
    }
  }

  Future<void> _saveLanguageAndProceed() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCodes = {'English': 'en', 'Arabic': 'ar'};
    await prefs.setString('language', languageCodes[_selectedLanguage] ?? 'en');

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignUpPage()));
  }

  Color _getTextColorBasedOnBackground() {
    double luminance = _backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black54 : Colors.grey;
  }
  @override
  Widget build(BuildContext context) {
    final textColor = _getTextColorBasedOnBackground();

    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: _backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
        child: Column(
          children: [

            const SizedBox(height: 40),
            Opacity(
              opacity: _showWelcomeUI ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !_showWelcomeUI,
                child: _buildLanguageSelector(),
              ),
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _controller,
                      child: Image.asset('assets/icon/img5.png', width: 80, height: 80),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: "MeQat".split("").asMap().entries.map((entry) {
                        int idx = entry.key;
                        String letter = entry.value;
                        return AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: _showLetters[idx] ? 1.0 : 0.0,
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontFamily: 'Scheherazade',
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Continue button + bottom MeQat text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Opacity(
                opacity: _showWelcomeUI ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !_showWelcomeUI,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.withOpacity(0.6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _saveLanguageAndProceed,
                    child: const SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("MeQat", style: TextStyle(color: Colors.grey, fontSize: 16)),
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
