import 'package:flutter/material.dart';
import 'package:meqat/UI.dart';
import 'package:meqat/sharedPref.dart';

import 'home.dart';
import 'signup.dart';

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
  String _selectedLanguage = "English";
  bool _hasUID = false;
  bool show=false;
  late AnimationController _controller;
  late Animation<int> _visibleLettersCount;


  @override
  void initState() {
    super.initState();
    getuid();

    // Initialize _showLetters with 'MeQat' letters
    _showLetters = List<bool>.filled('MeQat'.length, false);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _visibleLettersCount = StepTween(begin: 0, end: _showLetters.length).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start the animation always, regardless of UID presence
    _controller.forward().whenComplete(() async {
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        _backgroundColor = background;
      });

      await Future.delayed(Duration(milliseconds: 800));

      if (_hasUID) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        setState(() {
          show = true;
        });
      }
    });
  }




  Future<void> getuid() async {
    String? uid = await SharedPref().getUID();
    if(uid!.isNotEmpty){
      setState(() {
        _hasUID = true;
      });
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedLetters(Color textColor) {
    return AnimatedBuilder(
      animation: _visibleLettersCount,
      builder: (context, child) {
        int count = _visibleLettersCount.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_showLetters.length, (index) {
            return AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: index < count ? 1.0 : 0.0,
              child: Text(
                "MeQat"[index],
                style: TextStyle(
                  fontFamily: 'Scheherazade',
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Future<void> _saveLanguageAndProceed() async {
    await SharedPref().saveLanguage(_selectedLanguage == 'Arabic' ? 'ar' : 'en');
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
              opacity: show ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !show,
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
                    _buildAnimatedLetters(textColor),
                  ],
                ),
              ),
            ),

            // Continue button + bottom MeQat text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Opacity(
                opacity: show ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !show,
                  child: UIFunctions().buildRoundedButton(
                    title: "Continue",
                    onPressed: _saveLanguageAndProceed,
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
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedLanguage,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54, size: 20),
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        dropdownColor: background,
        borderRadius: BorderRadius.circular(12),
        onChanged: (String? newValue) {
          setState(() {
            _selectedLanguage = newValue!;
          });
        },
        items: ["English", "Arabic"].map((String value) {
          bool isSelected = _selectedLanguage == value;
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? fontColor : Colors.black.withOpacity(0.6), // cheerier unselected
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
