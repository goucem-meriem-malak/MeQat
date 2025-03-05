import 'package:flutter/material.dart';

class Other {

  List<Map<String, dynamic>> TypesOfDua = [
    {'title': 'Travel', 'icon': Icons.flight_takeoff},
    {'title': 'Ihram', 'icon': Icons.checkroom},
    {'title': 'Tawaf', 'icon': Icons.sync},
    {'title': 'Sa\'ee', 'icon': Icons.directions_walk},
    {'title': 'Hajj', 'icon': Icons.mosque},
    {'title': 'Umrah', 'icon': Icons.emoji_people},
    {'title': 'Worship', 'icon': Icons.handshake},
    {'title': 'Need', 'icon': Icons.favorite},
    {'title': 'Repentance', 'icon': Icons.volunteer_activism},
    {'title': 'Adoration', 'icon': Icons.star},
    {'title': 'Hope', 'icon': Icons.wb_sunny},
    {'title': 'Intercession', 'icon': Icons.group},
    {'title': 'Protection', 'icon': Icons.security},
    {'title': 'Istikhara', 'icon': Icons.lightbulb},
    {'title': 'All', 'icon': Icons.menu_book},
  ];
  List<Map<String, String>> TravelDua = [
    {"arabic": "اللهم إني أسألك...", "translation": "O Allah, I ask you..."},
    {"arabic": "أستغفر الله...", "translation": "I seek forgiveness from Allah..."},
    {"arabic": "الله أكبر...", "translation": "Glory be to Allah and praise be to Him..."},
  ];
  List<Map<String, dynamic>> menuItems = [
    {'title': 'Dua', 'icon': Icons.waving_hand},
    {'title': 'Ihram', 'icon': Icons.map},
    {'title': 'Hajj', 'icon': Icons.mosque},
    {'title': 'Umrah', 'icon': Icons.people},
    {'title': 'Face Scan', 'icon': Icons.face},
    {'title': 'Lost', 'icon': Icons.location_off},
    {'title': 'Dua', 'icon': Icons.menu_book},
    {'title': 'Dua', 'icon': Icons.library_books},
  ];
  List<String> languages = ["English", "Arabic"];
  List<String> goal = ["Hajj", "Umrah"];
  List<String> madhhabs = ["Shafii", "Hanafi", "Hanbali", "Maliki"];
  List<String> countries = ["Saudi Arabia", "Egypt", "Pakistan", "Malaysia", "Turkey"];
  List<String> transportationMethods = ["By Air", "By Sea", "By Vehicle", "By foot"];
}
