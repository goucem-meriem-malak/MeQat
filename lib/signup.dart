import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meqat/login.dart';
import 'package:meqat/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final Color buttonColor = Color(0xFFE5C99F);
final Color textColor = Color(0xC52E2E2E);

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class DateInputFormatter extends TextInputFormatter {
  static final String _mask = '__/__/____';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final oldText = oldValue.text;
    final newText = newValue.text;

    // Remove all non-digits
    final digits = newText.replaceAll(RegExp(r'[^0-9]'), '');

    StringBuffer buffer = StringBuffer();
    int digitIndex = 0;

    for (int i = 0; i < _mask.length; i++) {
      if (_mask[i] == '/') {
        buffer.write('/');
      } else {
        if (digitIndex < digits.length) {
          buffer.write(digits[digitIndex]);
          digitIndex++;
        } else {
          buffer.write('_');
        }
      }
    }

    // Calculate new cursor position (skip slashes)
    int cursorPosition = buffer.toString().indexOf('_');
    if (cursorPosition == -1) {
      cursorPosition = buffer.length;
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}


class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  bool _isAgreed = false;


  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus(); // Prevent soft keyboard and focus jump

    final DateTime now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10), // Allows selecting all future months/years
      helpText: 'Select Date', // Dialog title
      initialEntryMode: DatePickerEntryMode.input, // 👈 Input mode shown first
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepPurple, // Accent color
              onPrimary: Colors.white,    // Text on primary color
              onSurface: Colors.black,    // Default text color
            ),
            dialogBackgroundColor: Colors.white,
            dialogTheme: DialogTheme(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // ✅ Optional validation: disallow future dates
      if (picked.isAfter(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Birthdate cannot be in the future.")),
        );
      } else {
        // ✅ Format and assign selected date
        setState(() {
          _birthdateController.text = DateFormat('MM/dd/yyyy').format(picked);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      Center(
                        child: Text(
                          'Sign Up',
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
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _firstNameController,
                              hintText: "First name",
                              obscureText: false,
                              icon: Icons.person_2_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _lastNameController,
                              hintText: "Last name",
                              obscureText: false,
                              icon: Icons.person_2_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _emailController,
                              hintText: "Email",
                              obscureText: false,
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: "Password",
                              obscureText: true,
                              icon: Icons.key,
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _buildDateField(
                                  controller: _birthdateController,
                                  hintText: "Birthdate",
                                  obscureText: false,
                                  icon: Icons.date_range_outlined,
                                  inputFormatters: [DateInputFormatter()],
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ),

                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Checkbox(
                                  value: _isAgreed,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAgreed = value!;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isAgreed = !_isAgreed;
                                    });
                                  },
                                  child: const Text(
                                    "I agree to the terms and conditions",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline, // optional (to show it's clickable)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple.withOpacity(0.6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async {
                                if (_isAgreed) {
                                  saveSharedPreferences();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PreferencesPage(),
                                    ),
                                  );
                                }
                              },
                              child: const SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: icon != null
              ? Icon(
            icon,
            color: Colors.deepPurple,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required IconData? icon,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.deepPurple)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }



  Future<void> saveSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final docRef = FirebaseFirestore.instance.collection('users').doc();
    final uid = docRef.id;

    final userData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'birthday': _birthdateController.text.trim(),
      'uid': uid,
    };


    for (final entry in userData.entries) {
      await prefs.setString(entry.key, entry.value);
    }

    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity == ConnectivityResult.none) {
      await prefs.setBool('update', true);
      print("❌ No internet connection.");
      return;
    } else {
      await uploadToFirestore(userData);
      await prefs.setBool('update', false);
    }
  }

  Future<void> uploadToFirestore(Map<String, String> userData) async {
    final uid = userData['uid']!;
    final dataToUpload = Map<String, String>.from(userData)..remove('uid');
    await FirebaseFirestore.instance.collection('users').doc(uid).set(dataToUpload);
  }
}
