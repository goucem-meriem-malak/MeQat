import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:zxing2/qrcode.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:image_picker/image_picker.dart';

import 'package:image/image.dart' as img;
import 'dart:typed_data';

import '../../data/local/shared_pref.dart';
import '../../data/services/firebase_service.dart';
import '../helpers/ui_functions.dart';

class DelegationPage extends StatefulWidget {
  @override
  _DelegationPageState createState() => _DelegationPageState();
}
class _DelegationPageState extends State<DelegationPage> {
  StreamSubscription<Position>? _positionStreamSubscription;
  final LatLng makkahLatLng = LatLng(21.4225, 39.8262);
  bool showCheckmark = false;
  String? leaderName, firstName, lastName;
  Map<String, DateTime> lastAlarmTime = {};
  bool isAlarmDialogShowing = false;
  late GoogleMapController _mapController ;
  final Set<Marker> _markers = {};
  LatLng? lostUser;
  LatLng? userLocation;
  String? uid, qr;
  bool? leader = false;
  late List<Map<String, dynamic>> members;

  void updateGroupMarkers({
    required bool isLeader,
    required List<Map<String, dynamic>> members, // List of user maps with uid, firstName, lastName, location (LatLng)
    Map<String, dynamic>? leaderInfo, // Contains uid, firstName, lastName, location if user is not the leader
  }) {
    final Set<Marker> newMarkers = {};

    // Add all members
    for (var member in members) {
      final marker = Marker(
        markerId: MarkerId(member['uid']),
        position: member['location'] is LatLng
            ? member['location']
            : LatLng(
          (member['location'] as GeoPoint).latitude,
          (member['location'] as GeoPoint).longitude,
        ),
        infoWindow: InfoWindow(
          title: '${member['firstName']} ${member['lastName']}',
          snippet: AppLocalizations.of(context)!.group_member,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      newMarkers.add(marker);
    }

    if (!isLeader && leaderInfo != null) {
      final dynamic locationField = leaderInfo['location'];

      LatLng position;

      if (locationField is GeoPoint) {
        position = LatLng(locationField.latitude, locationField.longitude);
      } else if (locationField is LatLng) {
        position = locationField;
      } else {
        print("🚫 Invalid location type for leader: $locationField");
        return; // Skip adding marker
      }

      final leaderMarker = Marker(
        markerId: MarkerId(leaderInfo['uid']),
        position: position,
        infoWindow: InfoWindow(
          title: '${leaderInfo['firstName']} ${leaderInfo['lastName']}',
          snippet: AppLocalizations.of(context)!.group_leader,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      newMarkers.add(leaderMarker);
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }
  Future<void> _initialize() async {
    uid = await SharedPref().getUID();
    qr = await SharedPref().getQRCode();
    leader = await SharedPref().getLeader();
    firstName = await SharedPref().getFirstName();
    lastName = await SharedPref().getLastName();

    // Load members if qr exists
    if (qr != null && qr!.isNotEmpty) {
      if (leader == true) {
        if (uid != null) {
          final firstNameValue = await SharedPref().getFirstName();
          final lastNameValue = await SharedPref().getLastName();
          leaderName = "$firstNameValue $lastNameValue";

          members = await UpdateFirebase().getDelegationMembersInfo(uid!, qr!);
        }
      } else {
        members = await UpdateFirebase().getGroupMembersAndLeader(uid!, qr!);
        leaderInfo = await UpdateFirebase().getLeaderInfo(qr!);
      }
    }
    print("❌❌❌❌❌❌❌"+leaderInfo.toString());
    if(leaderInfo != null) {print("❌❌");updateGroupMarkers(isLeader: false, members: members, leaderInfo: leaderInfo);}
    _startListeningToLocationChanges();

    // Finally, update the UI
    setState(() {});
  }
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    LatLng target;

    if (lostUser != null) {
      target = lostUser!;
    } else if (userLocation != null) {
      target = userLocation!;
    } else {
      target = makkahLatLng;
    }

    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: lostUser != null ? 16 : (userLocation != null ? 14 : 12)),
      ),
    );
  }

  void _startListeningToLocationChanges() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.location_services_disabled)),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.location_permissions_denied)),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.location_permissions_permanently_denied)),
      );
      return;
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Only emit if user moved 10+ meters
      ),
    ).listen((Position position) {
      final newLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        userLocation = newLocation;
      });

      updateCameraToLocation(newLocation);
      UpdateFirebase().updateUserLocation(newLocation);
    });
  }
/*
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {userLocation = LatLng(position.latitude, position.longitude);});
    Future.delayed(const Duration(milliseconds: 300), () {
      updateCameraToUserLocation(userLocation!);
    });
    await UpdateFirebase().updateUserLocation(userLocation!);
  }
*/
  void updateCameraToLocation(LatLng target) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: lostUser != null ? 16 : (userLocation != null ? 14 : 12),
        ),
      ),
    );

    final markerId = MarkerId('target_marker');
    final marker = Marker(
      markerId: markerId,
      position: target,
      infoWindow: InfoWindow(title: 'Target Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId == markerId); // avoid duplicates
      _markers.add(marker);
    });
  }
  Map<String, dynamic>? leaderInfo;



  Future<void> checkIfMemberIsStrayingFromGroup(
      List<Map<String, dynamic>> members, // Excludes current user
      BuildContext context,
      ) async {
    const double maxAllowedDistance = 15.0; // meters
    const int cooldownSeconds = 300; // 5 minutes

    double closestDistance = double.infinity;

    for (var other in members) {
      final GeoPoint? geo = other['location'];
      if (geo == null) {
        print("🚫 Missing location data for member: $other");
        continue;
      }

      LatLng otherPos = LatLng(geo.latitude, geo.longitude);
      print("✅ Member location: ${otherPos.latitude}, ${otherPos.longitude}");

      double distance = Geolocator.distanceBetween(
        userLocation!.latitude,
        userLocation!.longitude,
        otherPos.latitude,
        otherPos.longitude,
      );

      if (distance < closestDistance) {
        closestDistance = distance;
      }
    }

    if (closestDistance > maxAllowedDistance) {
      DateTime now = DateTime.now();

      if (lastAlarmTime.containsKey(uid)) {
        DateTime lastTime = lastAlarmTime[uid]!;
        if (now.difference(lastTime).inSeconds < cooldownSeconds) {
          return; // Cooldown active
        }
      }

      setState(() {
        lostUser = userLocation;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        updateCameraToLocation(lostUser!); // Center camera on self
      });

      // Alert the user
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.user_straying),

          content: Text(
            AppLocalizations.of(context)!.too_far_from_group(firstName!, lastName!,),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        ),
      );

      startAlarmForUser(uid!, context);
      lastAlarmTime[uid!] = now;
    }
  }

  Future<void> checkIfLeaderDetectsStraying(
      List<Map<String, dynamic>> members, // Each contains uid, firstName, lastName, location (LatLng)
      BuildContext context,
      ) async {
    const double maxAllowedDistance = 15.0; // meters
    const int cooldownSeconds = 300; // 5 minutes

    for (var member in members) {
      String userId = member['uid'];
      LatLng userPos = member['location'];

      double closestDistance = double.infinity;

      for (var other in members) {
        if (userId == other['uid']) continue;

        LatLng otherPos = other['location'];

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

        setState(() {
          lostUser = userPos;
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          updateCameraToLocation(lostUser!); // Move camera to lost user
        });

        // Show full name alert to the leader
        String fullName = AppLocalizations.of(context)!.member_full_name_warning(member["firstName"], member["lastName"],
        );
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.member_straying),
            content: Text(
              AppLocalizations.of(context)!.leader_warning(fullName),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.ok),
              ),
            ],
          ),
        );

        // Optionally play sound or start other alerts
        startAlarmForUser(userId, context);

        lastAlarmTime[userId] = now;

        break; // Alert for one user only
      }
    }
  }

  bool _isStrayingCheckActive = false;
  void _startStrayingCheck() async {
    setState(() {
      _isStrayingCheckActive = !_isStrayingCheckActive; // toggle state
    });

    String message = _isStrayingCheckActive
        ? AppLocalizations.of(context)!.straying_service_on
        : AppLocalizations.of(context)!.straying_service_off;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_isStrayingCheckActive ? AppLocalizations.of(context)!.detection_on : AppLocalizations.of(context)!.detection_off),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );

    if (_isStrayingCheckActive) {
      if (leader == true) {
        await checkIfLeaderDetectsStraying(members, context);
      } else {
        await checkIfMemberIsStrayingFromGroup(members, context);
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
        title: Text(AppLocalizations.of(context)!.warning_title),
        content: Text(AppLocalizations.of(context)!.you_straying),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              isAlarmDialogShowing = false; // 🔥 Dialog closed
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
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
    try {
      final bytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;

      final pixels = Int32List(decodedImage.width * decodedImage.height);
      int index = 0;

      for (int y = 0; y < decodedImage.height; y++) {
        for (int x = 0; x < decodedImage.width; x++) {
          final pixel = decodedImage.getPixel(x, y);
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();

          final rgb = (r << 16) | (g << 8) | b;
          pixels[index++] = rgb;
        }
      }

      final luminanceSource = RGBLuminanceSource(
        decodedImage.width,
        decodedImage.height,
        pixels,
      );

      final bitmap = BinaryBitmap(HybridBinarizer(luminanceSource));
      final reader = QRCodeReader();

      final result = reader.decode(bitmap);

      print(result.text);
      return result.text;
    } catch (e) {
      print('QR decode error: $e');
      return null;
    }
  }
  void _showCheckmark() {
    setState(() {
      showCheckmark = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        showCheckmark = false;
      });
    });
  }
  Future<void> handleQRCode(String code) async {
    setState(() {
      qr = code;
    });
    await SharedPref().saveQRCode(code);
    _startListeningToLocationChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.delegation),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (qr != null)
            IconButton(
              icon: Icon(Icons.qr_code, color: Colors.deepPurple),
              onPressed: () {
                _showQRCodeSheet();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          _mapPage(),

          // Overlay QR panel if no QR exists and no checkmark
          if (qr == null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3), // Optional dim background
                child: Center(child: _qrPage()),
              ),
            ),

          // Show checkmark on top of everything
          if (showCheckmark)
            Positioned.fill(
              child: Center(
                child: const Icon(Icons.check_circle, size: 100, color: Colors.green),
              ),
            ),
        ],
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }

  Widget _qrPage(){
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
          child: Container(
          padding: const EdgeInsets.all(16),
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
                    Text(AppLocalizations.of(context)!.scan_qr_code, style: TextStyle(fontWeight: FontWeight.bold)),
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
                      child: Text(AppLocalizations.of(context)!.or, style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickFromGallery,
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.upload_from_gallery, style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Icon(Icons.image, color: Colors.deepPurple.withOpacity(0.6),size: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _mapPage() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(0.0, 0.0),
            zoom: 2,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _startStrayingCheck,
            backgroundColor: _isStrayingCheckActive ? Colors.green.shade900 : Colors.red.shade900,
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white,),
          ),
        ),
      ],
    );
  }

  void _showQRCodeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, // Transparent to allow custom color
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // QR Code
                      QrImageView(
                        data: qr ?? '',
                        version: QrVersions.auto,
                        size: 200,
                      ),

                      SizedBox(height: 16),

                      // Delegation members text
                      Text(
                        AppLocalizations.of(context)!.delegation_members,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),

                      SizedBox(height: 12),

                      // Members List or "No members yet"
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                      AppLocalizations.of(context)!.leader_name(leaderName!),
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                if (members.isEmpty)
                                  Text(AppLocalizations.of(context)!.no_members_yet, style: TextStyle(color: Colors.grey)),
                                if (members.isNotEmpty)
                                  SizedBox(
                                    height: 200,
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        itemCount: members.length,
                                        itemBuilder: (context, index) {
                                          final member = members[index];
                                          final fullName = '${member['firstName'] ?? ''} ${member['lastName'] ?? ''}'.trim();
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Center(
                                              child: Text(
                                                fullName.isNotEmpty ? fullName : AppLocalizations.of(context)!.unnamed_member,
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.scan_qr_code), centerTitle: true,),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.deepPurple,
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
