import 'package:flutter/material.dart';
import 'package:meqat/Dua.dart';
import 'package:meqat/Profile.dart';
import 'package:meqat/menu.dart';
import 'package:meqat/premium.dart';
import 'package:meqat/search.dart';
import 'Data.dart';
import 'UI.dart';
import 'home.dart';
final Other other = Other();

class DuasPage extends StatelessWidget {

  final List<Map<String, dynamic>> TypesOfDua = other.TypesOfDua;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duas', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.grey[300],
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (details.primaryVelocity! > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuPage()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
          child: GridView.builder(
            itemCount: TypesOfDua.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DuaPage()),
                    );
                  }
                  if (index == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DuasPage()),
                    );
                  }
                  if (index == 5) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DuasPage()),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(TypesOfDua[index]['icon'], size: 20, color: Colors.black),
                      const SizedBox(height: 6),
                      Text(
                        TypesOfDua[index]['title'],
                        style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500), // Adjusted text size
                      ),
                    ],
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
