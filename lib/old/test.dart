import 'dart:async';
import 'dart:io'; // For real internet check
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isConnected = false;
  bool updated = false;
  Timer? connectivityTimer;

  @override
  void initState() {
    super.initState();
    checkUpdatedAndConnectivity();
  }

  @override
  void dispose() {
    connectivityTimer?.cancel(); // Stop checking when widget is disposed
    super.dispose();
  }

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('age');
  }

  // Check if "updated" is true in SharedPreferences
  Future<void> checkUpdatedAndConnectivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? updated = prefs.getBool('updated') ?? false;

    if (updated) {
      checkInternetUntilConnected();
    }
  }

  // Keep checking connectivity & real internet access
  void checkInternetUntilConnected() {
    connectivityTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult != ConnectivityResult.none) {
        bool hasInternet = await hasRealInternet();

        if (hasInternet) {
          setState(() {
            isConnected = true;
            clearPreferences();
          });
          timer.cancel(); // Stop checking once fully connected
        }
      }
    });
  }

  // Function to check real internet by pinging Google
  Future<bool> hasRealInternet() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 3));
      return response.statusCode == 200;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Connectivity Checker")),
        body: Center(
          child: updated
              ? (isConnected
              ? Text("✅ Updated!", style: TextStyle(fontSize: 24, color: Colors.green))
              : Text("❌ Not Connected", style: TextStyle(fontSize: 20, color: Colors.red)))
              : Text("🚫 No Update", style: TextStyle(fontSize: 20, color: Colors.grey)),
        ),
      ),
    );
  }
}
