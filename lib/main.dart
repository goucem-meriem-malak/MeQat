import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meqat/Profile.dart';
import 'package:meqat/home.dart';
import 'package:meqat/medicine.dart';
import 'package:meqat/menu.dart';
import 'package:meqat/preferences.dart';
import 'package:meqat/sharedPref.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try {

    print('Starting Supabase init...');
    await Supabase.initialize(
      url: 'https://ktyugcnxddzqswkdnzph.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt0eXVnY254ZGR6cXN3a2RuenBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyNTYxOTgsImV4cCI6MjA2MzgzMjE5OH0.S9goAseWdcw83rfd0iDTD0xjC5H68IfVf4nOwuFhRIw',
    );
    print('Supabase initialized.');

    print('Starting Firebase init...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized.');


    final savedLangCode = await SharedPref().getLanguage();
    print('Got savedLangCode: $savedLangCode');

    print('✅✅✅✅✅✅✅✅✅✅✅✅✅here0000first');

    runApp(
      savedLangCode != null && savedLangCode.isNotEmpty
          ? MyApp(locale: Locale(savedLangCode))
          : const MyApp(),
    );
  } catch (e) {
    print("❌ Initialization error: $e");
  }
}


class MyApp extends StatefulWidget {
  final Locale? locale;

  const MyApp({super.key, this.locale});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;


  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  // Step 3: Update locale dynamically
  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
