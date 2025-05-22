import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meqat/Duas.dart';
import 'package:meqat/delegation.dart';
import 'package:meqat/Profile.dart';
import 'package:meqat/aipage.dart';
import 'package:meqat/old/home.dart';
import 'package:meqat/medicine.dart';
import 'package:meqat/menu.dart';
import 'package:meqat/preferences.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  InAppPurchase.instance.isAvailable();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AnimationScreen(),
        '/ai': (context) => AIPage(),
        '/menu': (context) => MenuPage(),
        '/settings': (context) => profilePage(),
        '/home': (context) => HomePage(),
        '/preferences': (context) => PreferencesPage(),
        '/duaa': (context) => DuasPage(),
        '/qr': (context) => DelegationPage(),
        '/medicine': (context) => MedicinePage(),
      },
    );
  }
}
