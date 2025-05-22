import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MaterialApp(
    home: LocalDuaPlayerPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class LocalDuaPlayerPage extends StatelessWidget {
  final AudioPlayer player = AudioPlayer();

  Future<void> playDua() async {
    await player.play(AssetSource('Dua/Duaasforthesujood.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Play Duʿāʼ Locally'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: playDua,
          icon: Icon(Icons.play_arrow),
          label: Text("Listen to أستغفر اللّٰه"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
