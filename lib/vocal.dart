import 'package:flutter/material.dart';
import 'package:meqat/lost.dart';
import 'package:meqat/medicine.dart';
import 'package:meqat/menu.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'UI.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Navigation App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VoiceCommandPage(),
    );
  }
}

class VoiceCommandPage extends StatefulWidget {
  @override
  _VoiceCommandPageState createState() => _VoiceCommandPageState();
}

class _VoiceCommandPageState extends State<VoiceCommandPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _command = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _command = result.recognizedWords.toLowerCase();
            });
            _handleCommand(_command);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleCommand(String command) {
    if (command.contains('menu')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuPage()),
      );
    } else if (command.contains('lost')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LostPage()),
      );
    } else if (command.contains('medicine')||command.contains('alarm')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MedicinePage()),
      );
    }  else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Command not recognized: $command')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Command Page')),
      body: Center(
        child: IconButton(
          icon: Icon(Icons.mic, size: 64),
          onPressed: _listen,
          color: _isListening ? Colors.red : Colors.blueGrey,
        ),
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(child: Text('Welcome to Profile Page', style: TextStyle(fontSize: 24))),
    );
  }
}
