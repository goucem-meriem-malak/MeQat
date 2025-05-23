import 'package:flutter/material.dart';
import 'package:meqat/Data.dart';
import 'package:meqat/delegation.dart';
import 'package:meqat/aipage.dart';
import 'package:meqat/faceRecognition.dart';
import 'package:meqat/hajj.dart';
import 'package:meqat/ihram.dart';
import 'package:meqat/lost.dart';
import 'package:meqat/medicine.dart';
import 'package:meqat/umrah.dart';
import 'UI.dart';
import 'home.dart';
final other = Other();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MenuPage());
}

class MenuPage extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = other.menuItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.grey[300],
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: GridView.builder(
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (index == 0) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DelegationPage()));
                    }
                    if (index == 1) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IhramTutorialPage()));
                    }
                    if (index == 2) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HajjTutorialPage()));
                    }
                    if (index == 3) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UmrahTutorialPage()));
                    }
                    if (index == 4) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LostPage()));
                    }
                    if (index == 5) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MedicinePage()));
                    }
                    if (index == 6) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MedicineAlarmApp()));
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(menuItems[index]['icon'], size: 28, color: Colors.deepPurple),
                        const SizedBox(height: 8),
                        Text(
                          menuItems[index]['title'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }
}
