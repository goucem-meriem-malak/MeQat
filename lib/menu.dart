import 'package:flutter/material.dart';
import 'package:meqat/Data.dart';
import 'package:meqat/delegation.dart';
import 'package:meqat/hajj.dart';
import 'package:meqat/ihram.dart';
import 'package:meqat/lost.dart';
import 'package:meqat/medicine.dart';
import 'package:meqat/search.dart';
import 'package:meqat/umrah.dart';
import 'UI.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
final other = Other();

class MenuPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = other.menuItems(context);
    return Scaffold(
      appBar: UIFunctions().buildAppBar(AppLocalizations.of(context)!.menu),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          }
        },
          child: SafeArea(
          bottom: true, // ensures padding from system nav bar
          child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // increased bottom padding
          child: GridView.builder(
            itemCount: menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    if (index == 0) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IhramTutorialPage()));
                    }
                    if (index == 1) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HajjTutorialPage()));
                    }
                    if (index == 2) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UmrahTutorialPage()));
                    }
                    if (index == 3) {

                      Navigator.push(context, MaterialPageRoute(builder: (context) => DelegationPage()));
                    }
                    if (index == 4) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LostPage()));
                    }
                    if (index == 5) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MedicinePage()));
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
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          menuItems[index]['image'],
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          menuItems[index]['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }
}
