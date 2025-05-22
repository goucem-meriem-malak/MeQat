import 'package:flutter/material.dart';
import 'package:meqat/premium.dart';
import 'package:meqat/search.dart';

import 'Data.dart';
import 'Profile.dart';
import 'UI.dart';
import 'home.dart';
import 'menu.dart';

class AIPage extends StatefulWidget {
  @override
  _AIPageState createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  void _handleCommand(String command) {
    setState(() {
      _messages.add("User: $command");
    });

    // Basic keyword-based intent parsing
    if (command.toLowerCase().contains("home")) {
      Navigator.pushNamed(context, '/home');
      _messages.add("AI: Navigating to home page.");
    } else if (command.toLowerCase().contains("settings")) {
      Navigator.pushNamed(context, '/settings');
      _messages.add("AI: Opening settings.");
    } else if (command.toLowerCase().contains("menu")) {
      Navigator.pushNamed(context, '/menu');
      _messages.add("AI: Going to menu page.");
    } else {
      _messages.add("AI: Sorry, I don't understand that command.");
    }

    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Navigator")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_messages[index]),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _handleCommand,
                    decoration: InputDecoration(
                      hintText: 'Ask me to open something...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _handleCommand(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }
}
