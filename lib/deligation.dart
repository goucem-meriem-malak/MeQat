import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Settings.dart';
import 'home.dart';
import 'menu.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DelegationMapPage(),
    );
  }
}

class DelegationMapPage extends StatefulWidget {

  const DelegationMapPage({Key? key}) : super(key: key);

  @override
  State<DelegationMapPage> createState() => _DelegationMapPageState();
}

class _DelegationMapPageState extends State<DelegationMapPage> {
  Map<String, DateTime> lastAlarmTime = {};

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
    const int cooldownSeconds = 10; // seconds before another alarm allowed

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
            // Still in cooldown, skip alarm
            continue;
          }
        }

        // 🔥 Trigger alarm
        startAlarmForUser(userId, context);

        // Update last alarm time
        lastAlarmTime[userId] = now;
      }
    }
  }

  void startAlarmForUser(String userId, BuildContext context) {
    print('🔔 Alarm triggered for user $userId!');

    // Play sound or vibration if you want here...

    // Show popup
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning!'),
        content: const Text('You are getting too far from your group. Please come back.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
        height: 60,
        child: BottomAppBar(
          color: Colors.white,
          elevation: 10,
          shadowColor: Colors.grey.shade400,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.workspace_premium),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
