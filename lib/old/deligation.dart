import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meqat/premium.dart';
import 'package:meqat/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../Data.dart';
import '../Profile.dart';
import '../home.dart';
import '../menu.dart';

class DelegationMapPage extends StatefulWidget {

  const DelegationMapPage({Key? key}) : super(key: key);

  @override
  State<DelegationMapPage> createState() => _DelegationMapPageState();
}

class _DelegationMapPageState extends State<DelegationMapPage> {
  Map<String, DateTime> lastAlarmTime = {}; // ✅ Track when last alarm triggered per user
  Map<String, bool> userAlarmCleared = {};  // ✅ Track if user pressed OK (alarm cleared)
  bool isAlarmDialogShowing = false;
  Map<String, LatLng> _userLocations = {}; // 🔥 Track all users' locations live
  int markerCounter = 0;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }


  Future<void> _initialize() async {
    try {
      await Firebase.initializeApp();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isDelegation = prefs.getBool('delegation');

      if (isDelegation == true) {
        String? qr = prefs.getString('qr');
        if (qr != null) {
          await _loadMembers(qr);

          // ✅ Start checking after members are loaded
          Timer.periodic(Duration(seconds: 10), (timer) {
            if (_userLocations.isNotEmpty) {
              checkIfMemberIsStraying(_userLocations, context);
            }
          });
        } else {
          print("❌ QR code is null!");
        }
      } else {
        print("ℹ️ Delegation is false or not set");
      }
    } catch (e) {
      print("❌ Error during initialization: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  LatLng _getCenterOfMarkers() {
    double lat = 0;
    double lng = 0;

    for (var marker in _markers) {
      lat += marker.position.latitude;
      lng += marker.position.longitude;
    }

    int count = _markers.length;
    return LatLng(lat / count, lng / count);
  }

  void _moveCameraToCenter() async {
    if (_markers.isEmpty) return;

    LatLng center = _getCenterOfMarkers();

    CameraPosition cameraPosition = CameraPosition(
      target: center,
      zoom: 10, // <<< You can set 13-15 depending how close you want
    );

    await _mapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
  }

  Future<void> _loadMembers(String qr) async {
    final delegationDoc = await FirebaseFirestore.instance
        .collection('deligation')
        .doc(qr)
        .get();

    if (delegationDoc.exists) {
      var data = delegationDoc.data();
      String? leaderId = data?['leader']; // 🔥 read leader UID
      List<dynamic>? members = data?['members']; // 🔥 read members list

      if (leaderId != null) {
        await _loadUserLocation(leaderId, isLeader: true); // ✅ load leader with yellow
      }

      if (members != null) {
        for (var memberId in members) {
          if (memberId != leaderId) { // ✅ skip leader if also inside members list
            await _loadUserLocation(memberId, isLeader: false); // ✅ load member with red
          }
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _moveCameraToCenter();
    });
  }


  Future<void> _loadUserLocation(String userId, {required bool isLeader}) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      var data = userDoc.data();
      String firstName = data?['firstName'] ?? '';
      String lastName = data?['lastName'] ?? '';
      GeoPoint? location = data?['location'];

      if (location != null) {
        double lat = location.latitude;
        double lng = location.longitude;

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId('marker_${userId}_${DateTime.now().millisecondsSinceEpoch}'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: '$firstName $lastName',
                snippet: isLeader ? 'Leader' : 'Member',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isLeader ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueRed,
              ),
            ),
          );

          // ✅ Save location
          _userLocations[userId] = LatLng(lat, lng);
        });

        print('✅ Added ${isLeader ? "Leader" : "Member"}: $firstName $lastName at ($lat, $lng)');
      } else {
        print('❌ Missing location for $userId');
      }
    } else {
      print('❌ User document does not exist for $userId');
    }
  }



  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> checkIfMemberIsStraying(
      Map<String, LatLng> userLocations, BuildContext context) async {
    const double maxAllowedDistance = 15.0; // meters
    const int cooldownSeconds = 300; // 5 minutes

    for (var entry in userLocations.entries) {
      String userId = entry.key;
      LatLng userPos = entry.value;

      double closestDistance = double.infinity;

      for (var otherEntry in userLocations.entries) {
        if (userId == otherEntry.key) continue; // Skip self

        LatLng otherPos = otherEntry.value;

        double distance = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          otherPos.latitude,
          otherPos.longitude,
        );

        if (distance < closestDistance) {
          closestDistance = distance;
        }
      }

      if (closestDistance > maxAllowedDistance) {
        DateTime now = DateTime.now();

        if (lastAlarmTime.containsKey(userId)) {
          DateTime lastTime = lastAlarmTime[userId]!;

          if (now.difference(lastTime).inSeconds < cooldownSeconds) {
            continue; // still in cooldown, skip
          }
        }

        // 🔥 Trigger alarm only once
        startAlarmForUser(userId, context);

        // Update last alarm time
        lastAlarmTime[userId] = now;

        break; // ✅ STOP checking after first alarm
      }
    }
  }


  void startAlarmForUser(String userId, BuildContext context) {
    if (isAlarmDialogShowing) {
      print('🚫 Alarm dialog already showing, skip new one.');
      return; // 🔥 Don't show multiple dialogs
    }

    isAlarmDialogShowing = true; // 🔥 Dialog is now open

    print('🔔 Alarm triggered for user $userId!');

    showDialog(
      context: context,
      barrierDismissible: false, // User MUST press OK
      builder: (context) => AlertDialog(
        title: const Text('Warning!'),
        content: const Text('You are getting too far from your group. Please come back.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              isAlarmDialogShowing = false; // 🔥 Dialog closed
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delegation Map')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 2,
        ),
        markers: _markers,
      ),
      bottomNavigationBar: SizedBox(
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
                child : UI().buildNavItem(Icons.menu, "Menu", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPage()));
                }, true),
              ),

              Expanded(
                child :  UI().buildNavItem(Icons.search, "Search", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
                }, false),
              ),

              Expanded(
                child : UI().buildNavItem(Icons.home, "Home", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
                }, false),),

              Expanded(
                child : UI().buildNavItem(Icons.star, "Premium", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumPage()));
                }, false),),

              Expanded(
                child : UI().buildNavItem(Icons.settings, "Profile", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => profilePage()));
                }, false),), // Profile is selected
            ],
          ),
        ),
      ),
    );
  }
}
