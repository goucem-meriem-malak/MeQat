import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../screens/Profile.dart';
import '../screens/adhan.dart';
import '../screens/home.dart';
import '../screens/premium.dart';
import '../screens/search.dart';

class UIFunctions {
  Widget buildNavItem(IconData icon, String label, VoidCallback onTap, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepPurple.withOpacity(0.8) : Colors.grey,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.deepPurple.withOpacity(0.8) : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavBar(BuildContext context, int selectedIndex) {
    return SizedBox(
      height: 70,
      child: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.grey.shade400,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: buildNavItem(Icons.menu, AppLocalizations.of(context)!.menu, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SalatHomePage()));
              }, selectedIndex == 0),
            ),
            Expanded(
              child: buildNavItem(Icons.search, AppLocalizations.of(context)!.search, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
              }, selectedIndex == 1),
            ),
            Expanded(
              child: buildNavItem(Icons.home, AppLocalizations.of(context)!.home, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
              }, selectedIndex == 2),
            ),
            Expanded(
              child: buildNavItem(Icons.star, AppLocalizations.of(context)!.premium, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumPage()));
              }, selectedIndex == 3),
            ),
            Expanded(
              child: buildNavItem(Icons.settings, AppLocalizations.of(context)!.profile, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              }, selectedIndex == 4),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(String title) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey[300],
      automaticallyImplyLeading: false,
    );
  }
  AppBar buildAppBarSub(String title) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.black)),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 4,
      shadowColor: Colors.grey[300],
      automaticallyImplyLeading: true,
    );
  }
  AppBar buildAppBarPremium(String title) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      centerTitle: true,
      backgroundColor: Color(0xFF3A7BD5),
      automaticallyImplyLeading: false,
    );
  }

  Widget buildRoundedButton({
    required String title,
    required VoidCallback onPressed,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.withOpacity(0.6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ),
      ),
    );
  }

}
