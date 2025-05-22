import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meqat/premium.dart';

import 'Profile.dart';
import 'home.dart';
import 'menu.dart';

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
              child: buildNavItem(Icons.menu, "Menu", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPage()));
              }, selectedIndex == 0),
            ),
            Expanded(
              child: buildNavItem(Icons.search, "Search", () {
                // Handle search
              }, selectedIndex == 1),
            ),
            Expanded(
              child: buildNavItem(Icons.home, "Home", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
              }, selectedIndex == 2),
            ),
            Expanded(
              child: buildNavItem(Icons.star, "Premium", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumPage()));
              }, selectedIndex == 3),
            ),
            Expanded(
              child: buildNavItem(Icons.settings, "Profile", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => profilePage()));
              }, selectedIndex == 4),
            ),
          ],
        ),
      ),
    );
  }
}
