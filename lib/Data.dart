import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Other {
  List<Map<String, dynamic>> miqatData = [
    {
      "name": "Dhul Hulaifa",
      "center": LatLng(24.413942807343183, 39.54297293708976),
      "closest": LatLng(24.390, 39.535),
      "farthest": LatLng(24.430, 39.550),
    },
    {
      "name": "Dhat Irq",
      "center": LatLng(21.930072877611384, 40.42552892351149),
      "closest": LatLng(21.910, 40.400),
      "farthest": LatLng(21.950, 40.450),
    },
    {
      "name": "Qarn al-Manazil",
      "center": LatLng(21.63320606975049, 40.42677866397942),
      "closest": LatLng(21.610, 40.410),
      "farthest": LatLng(21.650, 40.440),
    },
    {
      "name": "Yalamlam",
      "center": LatLng(20.518564356141052, 39.870803989418974),
      "closest": LatLng(20.500, 39.850),
      "farthest": LatLng(20.540, 39.890),
    },
    {
      "name": "Juhfa",
      "center": LatLng(22.71515249938801, 39.14514729649877),
      "closest": LatLng(22.700, 39.140),
      "farthest": LatLng(22.730, 39.160),
    },
  ];
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
    {'title': 'Medicine', 'icon': Icons.alarm},
    {'title': 'Deligation', 'icon': Icons.people},
    {'title': 'Q&A', 'icon': Icons.question_answer_outlined},
  ];
  List<String> languages = ["English", "Arabic"];
  List<String> goal = ["Hajj", "Umrah"];
  List<String> madhhabs = ["Shafii", "Hanafi", "Hanbali", "Maliki"];
  List<String> countries = ["Saudi Arabia", "Egypt", "Pakistan", "Malaysia", "Turkey"];
  List<String> transportationMethods = ["By Air", "By Sea", "By Vehicle", "By foot"];
}
