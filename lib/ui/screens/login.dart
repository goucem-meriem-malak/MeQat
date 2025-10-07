import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meqat/data/local/shared_pref.dart';

import '../helpers/ui_functions.dart';
import 'home.dart';
import 'signup.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class AuthService {


  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Auto-detect login method (email vs phone).
  Future<void> loginUser({
    required String username,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (_isEmail(username)) {
        // Email login
        UserCredential userCred = await _auth.signInWithEmailAndPassword(
          email: username.trim(),
          password: password.trim(),
        );

        await SharedPref().saveUId(userCred.user!.uid);
        await SharedPref().saveFirstTime(true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        // Phone login
        await _auth.verifyPhoneNumber(
          phoneNumber: username.trim(),
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-verification (on some devices)
            UserCredential userCred = await _auth.signInWithCredential(
                credential);

            await SharedPref().saveUId(userCred.user!.uid);
            await SharedPref().saveFirstTime(true);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Phone login failed: ${e.message}")),
            );
          },
          codeSent: (String verificationId, int? resendToken) async {
            final smsCode = await _askForSmsCode(context);

            if (smsCode != null && smsCode.isNotEmpty) {
              final credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: smsCode,
              );
              UserCredential userCred =
              await _auth.signInWithCredential(credential);

              await SharedPref().saveUId(userCred.user!.uid);
              await SharedPref().saveFirstTime(true);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'user-not-found') {
        msg = "No user found for that email/phone.";
      } else if (e.code == 'wrong-password') {
        msg = "Wrong password.";
      } else {
        msg = "Login failed: ${e.message}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  bool _isEmail(String input) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(input);
  }

  Future<String?> _askForSmsCode(BuildContext context) async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Enter SMS Code"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "123456"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }
}
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
      child: SingleChildScrollView(
      reverse: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              const Spacer(flex: 2),

              Center(
                child: Text(
                  AppLocalizations.of(context)!.welcome_back,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.deepPurpleAccent.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
              ),
              const SizedBox(height: 40),

              Center(
                child: Text(
                  AppLocalizations.of(context)!.signin_continue,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const Spacer(flex: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _usernameController,
                      hintText: AppLocalizations.of(context)!.login_methods,
                      obscureText: false,
                      icon: Icons.person_2_outlined,
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: AppLocalizations.of(context)!.pass,
                      obscureText: true,
                      icon: Icons.key,
                    ),
                    const SizedBox(height: 24),

                    UIFunctions().buildRoundedButton(title: AppLocalizations.of(context)!.login, onPressed: onPress),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.forgot_password,
                        style: TextStyle(
                          color: Colors.deepPurpleAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!isKeyboardOpen) const Spacer(flex: 1),

              if (!isKeyboardOpen)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.dontHaveAccount, style: TextStyle(color: Colors.black87)),
                        TextButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.create_account,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              if (!isKeyboardOpen)
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
      ),
      ),
    );
  }

  Future<void> onPress() async {
    final input = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your credentials")),
      );
      return;
    }

    // 👇 This is the important part
    await AuthService().loginUser(
      username: input,
      password: password,
      context: context,
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
          hintStyle: TextStyle(
            color: Colors.black45.withOpacity(0.4), // lighter, cheerier color
            fontWeight: FontWeight.w500, // optional: a bit bolder for friendliness
          ),
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
}
