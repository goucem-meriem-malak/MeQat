import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'UI.dart';
import 'lost.dart';
import 'medicine.dart';
import 'menu.dart';

void main() {
  runApp(MaterialApp(
    home: SearchPage(),
  ));
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _command = '';
  TextEditingController _searchController = TextEditingController();

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
      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()));
    } else if (command.contains('lost')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LostPage()));
    } else if (command.contains('medicine') || command.contains('alarm')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MedicinePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Command not recognized: $command')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Center(child: Text('MeQat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) => _handleCommand(value.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => _handleCommand(_searchController.text.toLowerCase()),
                  ),
                  filled: true,
                  fillColor: Colors.grey[300],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: _listen,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: _isListening ? Colors.green : Colors.grey[400],
                    child: Icon(Icons.mic, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 1),
    );
  }
}
