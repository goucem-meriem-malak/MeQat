import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meqat/Profile.dart';
import 'package:meqat/home.dart';
import 'package:meqat/medicine.dart';
import 'package:meqat/menu.dart';
import 'package:meqat/preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://ktyugcnxddzqswkdnzph.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0eXVnY254ZGR6cXN3a2RuenBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNTYxOTgsImV4cCI6MjA2MzgzMjE5OH0.S9goAseWdcw83rfd0iDTD0xjC5H68IfVf4nOwuFhRIw',
    );

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(MyApp());
  } catch (e, st) {
    print("❌ Initialization error: $e");
    print(st);
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'), // Default locale (optional)
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AnimationScreen(),
        '/menu': (context) => MenuPage(),
        '/settings': (context) => ProfilePage(),
        '/home': (context) => HomePage(),
        '/preferences': (context) => PreferencesPage(),
        '/medicine': (context) => MedicinePage(),
      },
    );
  }
}
