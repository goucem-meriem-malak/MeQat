import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:meqattest/Duas.dart';
import 'package:meqattest/Other.dart';
import 'package:meqattest/Settings.dart';
import 'package:meqattest/menu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

final other = Other();
class DuaPage extends StatefulWidget {
  @override
  _DuaPageState createState() => _DuaPageState();
}

class _DuaPageState extends State<DuaPage> {
  final GlobalKey _speedButtonKey = GlobalKey();
  final FlutterTts _flutterTts = FlutterTts();
  double speechRate = 1.0;
  int currentIndex = 0;
  String userLanguage = "";
  List<Map<String, String>> TravelDua = other.TravelDua;

  @override
  void initState() {
    super.initState();
    _loadUserLanguage();
  }

  Future<void> _loadUserLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userLanguage = prefs.getString('language') ?? "en";
    });
  }

  Future<void> _speak(String text, int index) async {
    await _flutterTts.setLanguage(userLanguage == "ar" ? "ar-SA" : "en-US");
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.speak(text);
    setState(() {
      currentIndex = index;
    });
  }

  void _changeSpeed() {
    List<double> speeds = [0.25, 0.5, 0.75, 1, 1.5, 2];
    final RenderBox button = _speedButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy + button.size.height,
        buttonPosition.dx + button.size.width,
        buttonPosition.dy + button.size.height + 50,
      ),
      items: speeds.map((speed) {
        return PopupMenuItem<double>(
          value: speed,
          child: Text(
            "${speed}x",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: speechRate == speed ? Colors.orange : Colors.black,
            ),
          ),
        );
      }).toList(),
    ).then((selectedSpeed) {
      if (selectedSpeed != null) {
        setState(() {
          speechRate = selectedSpeed;
        });
      }
    });
  }


  void _handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DuasPage()));
    } else if (details.primaryVelocity! < 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleSwipe,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            title: Text("Dua", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 2,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 2,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(TravelDua.length, (index) {
                          return Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex == index ? Colors.orange : Colors.grey,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: TravelDua.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 3,
                      color: Colors.white,
                      shadowColor: Colors.grey.shade200,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.volume_up, color: Colors.black),
                                  onPressed: () => _speak(TravelDua[index]["arabic"]!, index),
                                ),
                                Text("${speechRate}x", style: TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  key: _speedButtonKey,  // Assign the key here
                                  icon: Icon(Icons.speed, color: Colors.black),
                                  onPressed: _changeSpeed,
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                TravelDua[index]["arabic"]!,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              TravelDua[index]["translation"]!,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 10,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.black), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          ],
          onTap: (index) {
            if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()));
            if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
          },
        ),
      ),
    );
  }
}
