import 'package:flutter/material.dart';
import 'package:meqat/sharedPref.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'UI.dart';
import 'home.dart';
import 'menu.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _text = '';
  String _response = '';
  String _currentLocale = 'en-US';

  final List<Map<String, dynamic>> intents = [
    {
      'keywords': [
        'what is ihram', 'hello', 'what is a rum','define ihram', 'ihram meaning', 'ihram',
        'whats ihram', 'iran', 'ear arm', 'air ham',
        'احرام', 'الإحرام', 'ما هو الإحرام', 'تعريف الإحرام',
      ],
      'answer': 'Ihram is a sacred state Muslims enter for Hajj or Umrah.',
    },
    {
      'keywords': [
        'what is tawaf', 'tawaf', 'go off','define tawaf', 'tawaf meaning', 'tawaf', 'whats tawaf'
      ],
      'answer': 'Tawaf is the act of circumambulating the Kaaba seven times.',
    },
    {
      'keywords': [
        'what is saee', 'define saee', 'saee meaning', 'saee', 'whats saee'
      ],
      'answer': 'Sa\'ee is the act of walking between Safa and Marwah seven times.',
    },
    // Add more intents here
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() async {
    String? userLanguage = await SharedPref().getLanguage();
    if (userLanguage == null || userLanguage.isEmpty) {
      userLanguage = 'en';
    }
    setState(() {
      _currentLocale = (userLanguage == 'ar') ? 'ar-SA' : 'en-US';
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: _currentLocale,
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        listenFor: Duration(seconds: 10), // Listen for 10 seconds
        pauseFor: Duration(seconds: 3), // Wait for 3s pause before auto-stop
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopListening() async {
    setState(() => _isListening = false);
    await _speech.stop();
    _processSpeech();
  }

  void _processSpeech() async {
    if (_text.isEmpty) {
      setState(() => _response = AppLocalizations.of(context)!.no_speech_detected);
      await _tts.speak(_response);
      return;
    }

    for (var intent in intents) {
      for (var keyword in intent['keywords']) {
        if (_text.toLowerCase().contains(keyword.toLowerCase())) {
          setState(() => _response = intent['answer']);
          await _tts.speak(_response);
          return;
        }
      }
    }

    setState(() => _response = AppLocalizations.of(context)!.unknown_query);
    await _tts.speak(_response);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 50) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MenuPage()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      },
      child: Scaffold(
        appBar: UIFunctions().buildAppBar(AppLocalizations.of(context)!.search),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(0),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.search_text,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    if (_response.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            _response,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_isListening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.deepPurple.withOpacity(0.8) : Colors.deepPurple.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 1),
      ),
    );
  }
}
