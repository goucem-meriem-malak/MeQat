import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:meqat/premium.dart';
import 'package:meqat/search.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'Data.dart';
import 'Profile.dart';
import 'UI.dart';
import 'home.dart';

class DelegationPage extends StatefulWidget {
  @override
  _DelegationPageState createState() => _DelegationPageState();
}
class _DelegationPageState extends State<DelegationPage> {
  List<Map<String, dynamic>> membersList = [];
  bool? delegation;
  String? qrCode;
  bool? isLeader;
  bool showMembers = false;
  bool showCheckmark = false;
  String? leaderName;
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
    _loadPreferences();
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

    if (!delegationDoc.exists) return;

    final data = delegationDoc.data();
    final String? leaderId = data?['leader'];
    final List<dynamic>? members = data?['members'];

    List<Map<String, String>> loadedMembers = [];

    if (leaderId != null) {
      // ✅ Load leader location and add to members list
      final leaderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(leaderId)
          .get();

      if (leaderDoc.exists) {
        final leaderData = leaderDoc.data();
        final firstName = leaderData?['firstName'] ?? '';
        final lastName = leaderData?['lastName'] ?? '';
        loadedMembers.add({'firstName': firstName, 'lastName': lastName});

        await _loadUserLocation(leaderId, isLeader: true); // 🔥 Yellow marker for leader
      }
    }

    if (members != null && members.isNotEmpty) {
      for (var memberId in members) {
        if (memberId != leaderId) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .get();

          if (userDoc.exists) {
            final userData = userDoc.data();
            final firstName = userData?['firstName'] ?? '';
            final lastName = userData?['lastName'] ?? '';
            loadedMembers.add({'firstName': firstName, 'lastName': lastName});

            await _loadUserLocation(memberId, isLeader: false); // 🔥 Red marker for member
          }
        }
      }
    }

    setState(() {
      membersList = loadedMembers;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _moveCameraToCenter(); // 🔥 Move map camera after all markers are loaded
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

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    delegation = prefs.getBool('delegation') ?? false;
    qrCode = prefs.getString('qr');
    isLeader = prefs.getBool('leader') ?? false;

    if (delegation == true && qrCode != null) {
      if (isLeader == true) {
        final currentUserId = prefs.getString('uid'); // ensure this is saved
        if (currentUserId != null) {
          final firstName = prefs.getBool('firstName');
          final lastName = prefs.getBool('lastName');
          leaderName = "$firstName $lastName";
        }
      } else {
        // Get leader ID from delegation
        final delegationDoc = await FirebaseFirestore.instance
            .collection('deligation')
            .doc(qrCode)
            .get();

        if (delegationDoc.exists) {
          final data = delegationDoc.data();
          final leaderId = data?['leader'];
          if (leaderId != null) {
            final leaderDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(leaderId)
                .get();

            if (leaderDoc.exists) {
              final leaderData = leaderDoc.data();
              final firstName = leaderData?['firstName'] ?? '';
              final lastName = leaderData?['lastName'] ?? '';
              leaderName = "$firstName $lastName";
            }
          }
        }
      }
    }

    setState(() {});
  }

  void _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRScanPage()),
    );

    if (result != null && result is String) {
      handleQRCode(result);  // store the QR string and refresh
      _showCheckmark();      // optionally navigate forward
    }
  }

  void _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final qrCode = await _extractQRCode(File(pickedFile.path));
      if (qrCode != null) {
        handleQRCode(qrCode);
        _showCheckmark();
      } else {
        print("❌ No QR code found in the image.");
      }
    }
  }

  Future<String?> _extractQRCode(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final barcodeScanner = BarcodeScanner();

    final result = await barcodeScanner.processImage(inputImage);
    await barcodeScanner.close();

    if (result.isNotEmpty) {
      return result[0].displayValue;
    }
    return null;
  }

  void _showCheckmark() {
    setState(() {
      showCheckmark = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        showCheckmark = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(), // Replace with your actual home page
        ),
      );
    });
  }

  void handleQRCode(String code) {
    // Save QR and refresh UI
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('qr', code);
      setState(() {
        qrCode = code;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    /*if (delegation == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

     */

    return Scaffold(
      appBar: AppBar(
        title: Text('Delegation Page'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (qrCode != null)
            IconButton(
              icon: Icon(Icons.qr_code, color: Colors.deepPurple),
              onPressed: () {
                setState(() {
                  (_showQRCodeSheet);
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildBody(),
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }

  void _showQRCodeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: qrCode!,
                      version: QrVersions.auto,
                      size: 200,
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        if (!showMembers) {
                          await _loadMembers(qrCode!);
                        }
                        setState(() {
                          showMembers = !showMembers;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            "Delegation members",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          Icon(
                            showMembers ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    AnimatedCrossFade(
                      duration: Duration(milliseconds: 300),
                      crossFadeState: showMembers
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: 300,
                              maxHeight: 300,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (leaderName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "Leader $leaderName",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                if (membersList.isEmpty)
                                  Text("No members found.",
                                      style: TextStyle(color: Colors.grey)),
                                if (membersList.isNotEmpty)
                                  SizedBox(
                                    height: 200,
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        itemCount: membersList.length,
                                        itemBuilder: (context, index) {
                                          final member = membersList[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Center(
                                              child: Text(
                                                '${member['firstName']} ${member['lastName']}',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      secondChild: SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    if (qrCode == null || qrCode!.isEmpty || delegation == false) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _scanQRCode, // You'll define this below
                child: Column(
                  children: [
                    Text("Scan QRCode", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Icon(Icons.qr_code, color: Colors.deepPurple.withOpacity(0.6) ,size: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("OR", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickFromGallery,
                child: Column(
                  children: [
                    Text("Upload from Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Icon(Icons.image, color: Colors.deepPurple.withOpacity(0.6),size: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 2,
        ),
        markers: _markers,
      );
    }
  }
}

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}
class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code"), centerTitle: true,),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.blue,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      final qrCode = scanData.code;
      if (qrCode != null) {
        controller.pauseCamera();
        Navigator.pop(context, qrCode); // return QR string to previous page
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
