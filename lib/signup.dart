import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meqat/firebase.dart';
import 'package:meqat/login.dart';
import 'package:meqat/preferences.dart';
import 'package:meqat/sharedPref.dart';

import 'Data.dart';
import 'UI.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  bool _isAgreed = false;
  int _selectedYear = 2000; // class level variable, default 2000
  bool _fnameError = false;
  bool _lnameError = false;
  bool _emailError = false;
  bool _passwordError = false; // Example for text fields
  bool _birthError = false; // Example for text fields



  Future<void> _selectYear(BuildContext context) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    final currentYear = DateTime.now().year;
    final firstYear = currentYear - 110;

    int tempSelectedYear = _selectedYear; // Temp var to hold selection inside dialog

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 320,
            height: 400,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
            ),
            child: StatefulBuilder(
              builder: (context, setStateDialog) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select Year of Birth',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),

                    // Apply a Theme override to the YearPicker
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: Colors.deepPurple.shade200,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.deepPurple.shade100,
                            ),
                          ),
                        ),
                        child: YearPicker(
                          firstDate: DateTime(firstYear),
                          lastDate: DateTime(currentYear),
                          selectedDate: DateTime(tempSelectedYear),
                          onChanged: (DateTime dateTime) {
                            setStateDialog(() {
                              tempSelectedYear = dateTime.year;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // close dialog
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    FocusScope.of(context).unfocus();

    // Update the global _selectedYear with the tempSelectedYear after dialog closes
    setState(() {
      _selectedYear = tempSelectedYear;
      _birthdateController.text = _selectedYear.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
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
                      const Spacer(flex: 1),
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
                      const Spacer(flex: 1),
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
                              hasError: _fnameError,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _lastNameController,
                              hintText: "First name",
                              obscureText: false,
                              icon: Icons.person_2_outlined,
                              hasError: _lnameError,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _emailController,
                              hintText: "Email",
                              obscureText: false,
                              icon: Icons.email_outlined,
                              hasError: _emailError,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: "Password",
                              obscureText: true,
                              icon: Icons.key,
                              hasError: _passwordError,
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                _selectYear(context);
                              },
                              child: AbsorbPointer(
                                child: _buildDateField(
                                  controller: _birthdateController,
                                  hintText: "Birthdate",
                                  obscureText: false,
                                  icon: Icons.date_range_outlined,
                                  inputFormatters: [DateInputFormatter()],
                                  keyboardType: TextInputType.number,
                                  hasError: _birthError,
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _isAgreed,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAgreed = value ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      setState(() {
                                        _isAgreed = !_isAgreed;
                                      });
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: 'I agree to the ',
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                setState(() {
                                                  _isAgreed = !_isAgreed;
                                                });
                                              },
                                          ),
                                          TextSpan(
                                            text: 'terms and conditions',
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                              decoration: TextDecoration.underline,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                FocusManager.instance.primaryFocus?.unfocus();
                                                final agreed = await Navigator.push<bool>(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => TermsAndConditionsPage(),
                                                  ),
                                                );

                                                if (agreed == true) {
                                                  setState(() {
                                                    _isAgreed = true;
                                                  });
                                                }
                                              },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            UIFunctions().buildRoundedButton(
                              title: "Sign Up",
                              onPressed: onPress,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      if (!isKeyboardOpen)
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
  Future<void> onPress() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _fnameError = _firstNameController.text.trim().isEmpty;
      _lnameError = _lastNameController.text.trim().isEmpty;
      _emailError = _emailController.text.trim().isEmpty;
      _passwordError = _passwordController.text.trim().isEmpty;
      _birthError = _birthdateController.text.trim().isEmpty;
    });

    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must agree to the terms and conditions.")),
      );
      return;
    }

    if (_fnameError || _lnameError || _emailError || _passwordError || _birthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    // All good, proceed
    await saveSharedPreferences();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreferencesPage(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required IconData? icon,
    bool hasError = false,
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
          hintStyle: TextStyle(
            color: Colors.black45.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.transparent,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.deepPurpleAccent,
              width: 1.5,
            ),
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
    bool hasError = false,
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
          hintStyle: TextStyle(
            color: Colors.black45.withOpacity(0.4),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: icon != null ? Icon(icon, color: Colors.deepPurple) : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.transparent,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.deepPurpleAccent,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> saveSharedPreferences() async {
    final uid = await UpdateFirebase().createDoc('users');
    await SharedPref().saveUId(uid);

    myUser user = myUser();
    user.firstName = _firstNameController.text.trim();
    user.lastName = _lastNameController.text.trim();
    user.email = _emailController.text.trim();
    user.password = _passwordController.text.trim();
    user.birthday = _birthdateController.text.trim();

    await SharedPref().saveUser(user);
    await UpdateFirebase().addUser(user, uid);
  }
}

class DateInputFormatter extends TextInputFormatter {
  static final String _mask = '__/__/____';

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final newText = newValue.text;

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

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please read carefully',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    '''Welcome to our app’s Terms and Conditions.

By using this app, you agree to the following terms:

- You acknowledge that the information provided is for general purposes.
- We are not liable for any damages arising from the use.
- Please ensure you use the app responsibly and respect privacy policies.

Thank you for taking the time to read this. If you have questions, please contact support.

Happy using!''',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                elevation: 5,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Agree',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

