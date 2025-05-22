import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class MyApp {
  bool isConnected = false;
  bool updated = false;
  Timer? connectivityTimer;

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('name');
    await prefs.remove('age');
  }

  Future<bool> checkUpdatedAndConnectivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? updated = prefs.getBool('updated') ?? false;

    if (updated) {
      return true;
    }
    return false;
  }

  Future<bool> checkInternetUntilConnected() async {
    Completer<bool> completer = Completer<bool>(); // To return a value later

    connectivityTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult != ConnectivityResult.none) {
        bool hasInternet = await hasRealInternet();

        if (hasInternet) {
          isConnected = true;
          clearPreferences();
          timer.cancel();
          completer.complete(true); // Return true when connected
        }
      }
    });

    return completer.future; // Wait until connection is established
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
}
