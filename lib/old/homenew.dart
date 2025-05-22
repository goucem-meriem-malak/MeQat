import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meqat/ihram.dart';
import 'package:meqat/premium.dart';
import 'package:meqat/search.dart';
import 'package:window_manager/window_manager.dart';

import '../Profile.dart';
import '../menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late final StreamSubscription<ServiceStatus> _locationStatusSubscription;
  late GoogleMapController mapController;

  final DraggableScrollableController _scrollController = DraggableScrollableController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final LatLng makkahLocation = LatLng(24.422534, 39.583691);
  LatLng? _userLocation = LatLng(19.980817, 42.595958);

  String? _errorMessage;

  double _currentChildSize = 0.1;

  int _error = 0; // 0 = none, 1 = no internet, 2 = no location, 3 = failed to get location
  int _locationIndex = 0;
  int? _selectedSayingIndex = null;

  bool _isLocationDialogShown = false;
  bool _isInternetDialogShown = false;
  bool _wasInsideMiqat = false;
  bool _notifiedBeforeEntry = false;
  bool _isPlaying = false;
  bool showPolygons = false;
  bool alarmPlaying = false;
  bool userDecisionMade = false;
  bool insideMiqatRing = false;
  bool showMiqatMarkers = false;
  bool wasInsideMiqatRing = false;
  bool hasReceived5MinWarning = false;
  bool wasInsideMiqatPolygon = false;
  bool wasInsideSectorRing = false;
  bool wasInsideCircle = false;
  bool wasNearMiqatLine = false;
  bool hasRespondedToMiqatDialog = false;
  bool skipMiqatReminder = false;


  Position? _lastPosition;

  Set<Marker> selectedMarkers = {};
  Marker? selectedMarker;
  Set<Polygon> annulus = {};
  Set<Polygon> polygons = {};
  Set<Polyline> miqatLines = {};
  Set<Polyline> Lines = {};

  final List<Map<String, dynamic>> miqatData = [
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
  List<Map<String, double>> mockLocations = [
    {"lat": 19.980817, "lng": 42.595958}, // Location 1
    {"lat": 24.429102, "lng": 39.585716},   // Location 2
    {"lat": 24.422534, "lng": 39.583691},
    {"lat": 24.358981, "lng": 39.614368},// Location 3
  ];
  List<String> _sayingDescriptions = [
    "Is not approved by any madhhab",  // Saying 1
    "Is not approved by any madhhab",  // Saying 2
    "Saying 3 is approved by all 4 madhhabs",  // Saying 3
    "Description for Saying 4",  // Saying 4
    "Only approved by madhhab Hanbali",  // Saying 5
  ];


  Timer? _locationTimer;


  @override
  void initState() {
    super.initState();
    _selectedSayingIndex = 2;
    showSaying(2);
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      if (!results.contains(ConnectivityResult.none)) {
        await _checkAndFetchLocation();
      }
    });

    _locationStatusSubscription =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) async {
          if (status == ServiceStatus.enabled) {
            await _checkAndFetchLocation();
          } else {
            if (!_isLocationDialogShown) {
              _showLocationDialog();
            }
          }
        });
    startLocationMonitoring();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _locationTimer?.cancel();
    _connectivitySubscription.cancel();
    _locationStatusSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: makkahLocation,
              zoom: 6,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              if (selectedMarker != null) selectedMarker!,
              Marker(
                markerId: MarkerId("makkah"),
                position: makkahLocation,
                infoWindow: InfoWindow(title: "Makkah"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
              ),
              Marker(
                markerId: MarkerId("userLocation"),
                position: _userLocation!,
                infoWindow: InfoWindow(title: "Your Location"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
              ...selectedMarkers,
            },
            polygons: {
              ...annulus,
              ...polygons,
            },
            polylines: miqatLines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),

          if (_errorMessage != null && _error != 0)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                color: Colors.red.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          DraggableScrollableSheet(
            controller: _scrollController,
            expand: true, // ✅ keep it TRUE so it stays at bottom
            initialChildSize: 0.16,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          5,
                              (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedSayingIndex == index ? Colors.orange : Colors.black,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedSayingIndex = index; // Update the selected saying index
                                });
                                showSaying(index);
                              },
                              child: Text(
                                'Saying ${index + 1}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// **Show Description Instead of Grid**
                    if (_selectedSayingIndex != null)
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: ClampingScrollPhysics(), // ✅ <<< added this to fix pulling
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _sayingDescriptions[_selectedSayingIndex!],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
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
                    MaterialPageRoute(builder: (context) => SearchPage()),
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
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.workspace_premium),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PremiumPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => profilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkAndFetchLocation() async {
    bool hasInternet = await _hasInternetAccess();
    if (!hasInternet) {
      if (!_isInternetDialogShown) {
        _showInternetDialog();
      }
      return;
    } else {
      if (_error == 1) {
        setState(() {
          _error = 0;
          _errorMessage = null;
        });
      }
    }

    bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationServiceEnabled) {
      if (!_isLocationDialogShown) {
        _showLocationDialog();
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _error = 2;
        _errorMessage = 'Location permission denied.';
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _error = 0;
        _errorMessage = null;
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_userLocation!, 14.0),
        );
      }
    } catch (e) {
      setState(() {
        _error = 3;
        _errorMessage = 'Failed to get location';
      });
    }
  }

  Future<bool> _hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showInternetDialog() {
    setState(() {
      _isInternetDialogShown = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('No Internet Connection'),
          content: Text('Check your internet connection.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _error = 1;
                  _errorMessage = 'No internet connection.';
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationDialog() {
    setState(() {
      _isLocationDialogShown = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Disabled Location'),
          content: Text('Turn on your location services.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _error = 2;
                  _errorMessage = 'Location services are disabled.';
                });
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void resetMap() {
    setState(() {
      selectedMarkers.clear();
      annulus.clear();
      polygons.clear();
      miqatLines.clear();
      showPolygons = false;
      showMiqatMarkers = false;
    });
  }

  void _onSayingPressed(int index) {
    setState(() {
      _selectedSayingIndex = index;
      _sayingDescriptions[index];
      _currentChildSize = 0.3;
    });
    _scrollController.animateTo(
      0.3,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void showSaying(int index){
    _onSayingPressed(index);
    switch (index) {
      case 0:
        checkUserLocationSaying1();
        showSaying1();
        break;
      case 1:
        checkUserLocationSaying2();
        showSaying2();
        break;
      case 2:
        checkUserLocationSaying3();
        showSaying3();
        break;
      case 3:
        checkUserLocationSaying4();
        showSaying4();
        break;
      case 4:
        checkUserLocationSaying5();
        showSaying5();
        break;
    }
    if(_userLocation!=null){
      startLocationMonitoring();
    }
    _sayingDescriptions[index];
  }

  void startLocationMonitoring() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (_userLocation != null) {
        if(_selectedSayingIndex==0){
          checkUserLocationSaying1();
        }
        if(_selectedSayingIndex==1){
          checkUserLocationSaying2();
        }
        if(_selectedSayingIndex==2){
          checkUserLocationSaying3();
        }
        if(_selectedSayingIndex==3){
          checkUserLocationSaying4();
        }
        if(_selectedSayingIndex==4){
          checkUserLocationSaying5();
        }
      }
    });
  }

  void showSaying1() {
    resetMap();
    setState(() {
      selectedMarkers.clear();
      annulus.clear();
      showPolygons = false;

      for (var miqat in miqatData) {
        LatLng center = miqat["center"];
        LatLng closest = miqat["closest"];
        LatLng farthest = miqat["farthest"];

        double innerRadius = calculateDistance(makkahLocation, closest);
        double outerRadius = calculateDistance(makkahLocation, farthest);

        List<LatLng> outerCircle = createCircle(makkahLocation, outerRadius, 72);
        List<LatLng> innerCircle = createCircle(makkahLocation, innerRadius, 72);

        annulus.add(Polygon(
          polygonId: PolygonId("${miqat["name"]}_annulus"),
          points: outerCircle,
          holes: [innerCircle],
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ));

        selectedMarkers.add(Marker(
          markerId: MarkerId(miqat["name"]),
          position: center,
          infoWindow: InfoWindow(title: miqat["name"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      }

      showMiqatMarkers = true;
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 8),
    );
  }
  void showSaying2() {
    resetMap();
    List<LatLng> outerPoints = [
      miqatData[0]["farthest"], miqatData[1]["farthest"], miqatData[2]["farthest"], miqatData[3]["farthest"], miqatData[4]["farthest"], miqatData[0]["farthest"]
    ];
    List<LatLng> innerPoints = [
      miqatData[0]["closest"], miqatData[1]["closest"], miqatData[2]["closest"], miqatData[3]["closest"], miqatData[4]["closest"], miqatData[0]["closest"]
    ];

    setState(() {
      polygons.clear();
      showPolygons = true;

      polygons = {
        Polygon(
          polygonId: PolygonId("miqat_zone"),
          points: [...outerPoints, ...innerPoints.reversed],
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
        Polygon(
          polygonId: PolygonId("miqat_inner"),
          points: innerPoints,
          fillColor: Colors.transparent,
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
        Polygon(
          polygonId: PolygonId("miqat_outer"),
          points: outerPoints,
          fillColor: Colors.transparent,
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    });
  }
  void showSaying3() {
    resetMap();
    setState(() {
      annulus.clear();
      selectedMarkers.clear();

      for (var miqat in miqatData) {
        LatLng center = miqat["center"];
        double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
        double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

        List<LatLng> outerSector = createOpenSector(makkahLocation, center, outerRadius);
        List<LatLng> innerSector = createOpenSector(makkahLocation, center, innerRadius);

        selectedMarkers.add(Marker(
          markerId: MarkerId(miqat["name"]),
          position: center,
          infoWindow: InfoWindow(title: miqat["name"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));

        annulus.add(Polygon(
          polygonId: PolygonId("${miqat["name"]}_sector"),
          points: [...outerSector, ...innerSector.reversed],
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ));
      }
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 8),
    );
  }
  void showSaying4() {
    resetMap();
    Set<Polyline> newLines = {};

    for (var miqat in miqatData) {
      LatLng miqatCenter = miqat["center"];
      String miqatName = miqat["name"];

      newLines.add(Polyline(
        polylineId: PolylineId("direct_$miqatName"),
        color: Colors.red,
        width: 3,
        points: [miqatCenter, makkahLocation],
      ));

      double miqatDistance = _calculateDistance(miqatCenter, makkahLocation);
      double lineThickness = (miqatDistance / 1000).clamp(3, 10).toDouble();

      double dx = makkahLocation.latitude - miqatCenter.latitude;
      double dy = makkahLocation.longitude - miqatCenter.longitude;
      double length = sqrt(dx * dx + dy * dy);

      double normX = dx / length;
      double normY = dy / length;

      double perpX = -normY;
      double perpY = normX;

      double miqatLineLength = (miqatDistance / 200000);

      LatLng miqatLineStart = LatLng(
        miqatCenter.latitude + perpX * miqatLineLength,
        miqatCenter.longitude + perpY * miqatLineLength,
      );
      LatLng miqatLineEnd = LatLng(
        miqatCenter.latitude - perpX * miqatLineLength,
        miqatCenter.longitude - perpY * miqatLineLength,
      );

      newLines.add(Polyline(
        polylineId: PolylineId("miqatline_$miqatName"),
        color: Colors.blue,
        width: lineThickness.toInt(),
        points: [miqatLineStart, miqatLineEnd],
      ));
    }

    setState(() {
      miqatLines = newLines;
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 6),
    );
  }
  void showSaying5() {
    resetMap();
    Set<Polyline> newLines = {
      Polyline(
        polylineId: PolylineId("direct_line"),
        color: Colors.red,
        width: 3,
        points: [_userLocation!, makkahLocation],
      ),
    };

    for (var miqat in miqatData) {
      LatLng miqatCenter = miqat["center"];
      double miqatDistance = _calculateDistance(miqatCenter, makkahLocation);
      double lineThickness = (miqatDistance / 1000).clamp(3, 10).toDouble();

      double dx = makkahLocation.latitude - miqatCenter.latitude;
      double dy = makkahLocation.longitude - miqatCenter.longitude;
      double length = sqrt(dx * dx + dy * dy);

      double normX = dx / length;
      double normY = dy / length;

      double perpX = -normY;
      double perpY = normX;

      double miqatLineLength = (miqatDistance / 200000);

      LatLng miqatLineStart = LatLng(
        miqatCenter.latitude + perpX * miqatLineLength,
        miqatCenter.longitude + perpY * miqatLineLength,
      );
      LatLng miqatLineEnd = LatLng(
        miqatCenter.latitude - perpX * miqatLineLength,
        miqatCenter.longitude - perpY * miqatLineLength,
      );

      newLines.add(Polyline(
        polylineId: PolylineId("miqatline_${miqat["name"]}"),
        color: Colors.blue,
        width: lineThickness.toInt(),
        points: [miqatLineStart, miqatLineEnd],
      ));
    }

    setState(() {
      miqatLines = newLines;
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 6),
    );
  }

  void checkUserLocationSaying1() {
    if (userDecisionMade) return;
    double userDistance = calculateDistance(makkahLocation, _userLocation!);
    bool currentlyInsideMiqat = false;

    for (var miqat in miqatData) {
      double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
      double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

      // CASE 1: Approaching the ring (about 420m from outer radius)
      if (!wasInsideMiqatRing &&
          userDistance <= outerRadius + 420 &&
          userDistance > outerRadius &&
          !hasReceived5MinWarning) {
        startAlarm();
        _showApproachNotification();
        hasReceived5MinWarning = true;
      }

      // CASE 2: Inside the Miqat ring
      if (userDistance <= outerRadius && userDistance >= innerRadius) {
        currentlyInsideMiqat = true;

        if (!wasInsideMiqatRing) {
          // Triggered when entering
          startAlarm();
          _showInsideMiqatNotification();

          showWindowsNotification(context);
          wasInsideMiqatRing = true;
          hasReceived5MinWarning = false;
        }

        break;
      }
    }

    // CASE 3: Exiting the Miqat ring going toward Makkah
    if (!currentlyInsideMiqat && wasInsideMiqatRing) {
      startAlarm();
      _showExitWarningNotification();

      wasInsideMiqatRing = false;
      hasReceived5MinWarning = false;
    }
  }
  void checkUserLocationSaying2() {
    List<LatLng> outerPoints = miqatData.map((e) => e["farthest"] as LatLng).toList();
    List<LatLng> innerPoints = miqatData.map((e) => e["closest"] as LatLng).toList();

    bool insideOuter = isPointInsidePolygon(_userLocation!, outerPoints);
    bool insideInner = isPointInsidePolygon(_userLocation!, innerPoints);
    bool insideZone = insideOuter;

    // Check distance to closest point on the polygon (approximate warning zone)
    double minDistanceToPolygon = double.infinity;
    for (var point in outerPoints) {
      double d = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        point.latitude,
        point.longitude,
      );
      if (d < minDistanceToPolygon) {
        minDistanceToPolygon = d;
      }
    }

    // CASE 1: 5 min before entry (≈420 meters away)
    if (!wasInsideMiqatPolygon && minDistanceToPolygon <= 420 && !hasReceived5MinWarning) {
      startAlarm();
      _showApproachNotification();
      hasReceived5MinWarning = true;
    }

    // CASE 2: Entered the Miqat zone
    if (insideZone && !wasInsideMiqatPolygon) {
      startAlarm();
      _showInsideMiqatNotification();

      showWindowsNotification(context);

      setState(() {
        insideMiqatRing = true;
      });

      wasInsideMiqatPolygon = true;
      hasReceived5MinWarning = false;
    }

    // CASE 3: Exited the Miqat zone
    if (!insideZone && wasInsideMiqatPolygon) {
      startAlarm();
      _showExitWarningNotification();

      setState(() {
        insideMiqatRing = false;
      });

      wasInsideMiqatPolygon = false;
      hasReceived5MinWarning = false;
    }

    if (!userDecisionMade) {
      Future.delayed(Duration(seconds: 3), () {
        checkUserLocationSaying2();
      });
    }
  }
  void checkUserLocationSaying3() {
    if (userDecisionMade) return;

    double userDistance = calculateDistance(makkahLocation, _userLocation!);
    bool currentlyInside = false;

    for (var miqat in miqatData) {
      double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
      double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

      if (userDistance <= outerRadius) {
        double userBearing = calculateBearing(makkahLocation, _userLocation!);
        double miqatBearing = calculateBearing(makkahLocation, miqat["closest"]);

        double minAngle = (miqatBearing - 60) % 360;
        double maxAngle = (miqatBearing + 60) % 360;

        bool inSector = isBearingInRange(userBearing, minAngle, maxAngle);

        if (inSector) {
          currentlyInside = true;

          // Case 1: 5-minute warning (approx 420 meters before entry)
          if (!wasInsideSectorRing && !hasReceived5MinWarning && userDistance > innerRadius && (outerRadius - userDistance <= 420)) {
            startAlarm();
            _showApproachNotification();
            hasReceived5MinWarning = true;
          }

          // Case 2: Entering Miqat Ring + Sector
          if (!wasInsideSectorRing) {
            startAlarm();
            _showInsideMiqatNotification();

            setState(() {
              insideMiqatRing = true;
            });

            showWindowsNotification(context);
          }

          wasInsideSectorRing = true;
          break;
        }
      }
    }

    // Case 3: Exited Miqat Ring + Sector
    if (!currentlyInside && wasInsideSectorRing) {
      startAlarm();
      _showExitWarningNotification();

      setState(() {
        insideMiqatRing = false;
      });

      wasInsideSectorRing = false;
      hasReceived5MinWarning = false;
    }

    if (!userDecisionMade) {
      Future.delayed(Duration(seconds: 3), () {
        checkUserLocationSaying3();
      });
    }
  }
  void checkUserLocationSaying4() {
    if (userDecisionMade) return;

    bool currentlyInside = false;

    for (var miqat in miqatData) {
      double distance = _calculateDistance(_userLocation!, miqat["center"]);

      // 1. Early Warning ~5 mins before
      if (!wasInsideCircle && !hasReceived5MinWarning && distance <= 1420 && distance > 1000) {
        startAlarm();
        _showApproachNotification();
        hasReceived5MinWarning = true;
      }

      // 2. Inside Miqat (Entry)
      if (distance <= 1000) {
        currentlyInside = true;

        if (!wasInsideCircle) {
          startAlarm();
          _showInsideMiqatNotification();

          setState(() {
            insideMiqatRing = true;
          });

          showWindowsNotification(context);
        }

        break; // Exit loop after finding 1 match
      }
    }

    // 3. Exit Detection
    if (!currentlyInside && wasInsideCircle) {
      startAlarm();
      _showExitWarningNotification();

      setState(() {
        insideMiqatRing = false;
      });

      hasReceived5MinWarning = false;
    }

    wasInsideCircle = currentlyInside;

    // 4. Re-check loop
    if (!userDecisionMade) {
      Future.delayed(Duration(seconds: 3), () {
        checkUserLocationSaying4();
      });
    }
  }
  void checkUserLocationSaying5() {
    if (userDecisionMade) return;

    double userDistanceToMiqatLine = _calculateDistance(
      _userLocation!,
      miqatLines.first.points.first, // You can loop through all points if needed
    );

    bool currentlyNear = userDistanceToMiqatLine <= 1000;

    // 1. 5-minute early warning (~420m before)
    if (!hasReceived5MinWarning &&
        userDistanceToMiqatLine <= 1420 &&
        userDistanceToMiqatLine > 1000) {
      startAlarm();
      _showApproachNotification();
      hasReceived5MinWarning = true;
    }

    // 2. User enters
    if (currentlyNear && !wasNearMiqatLine) {
      _showInsideMiqatNotification();
      startAlarm();

      setState(() {
        insideMiqatRing = true;
      });

      showWindowsNotification(context);
    }

    // 3. User exits
    if (!currentlyNear && wasNearMiqatLine) {
      startAlarm();
      _showExitWarningNotification();

      setState(() {
        insideMiqatRing = false;
      });

      hasReceived5MinWarning = false;
    }

    wasNearMiqatLine = currentlyNear;

    // 4. Repeat check
    if (!userDecisionMade) {
      Future.delayed(Duration(seconds: 3), () {
        checkUserLocationSaying5();
      });
    }
  }

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    return distance;
  }
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000;
    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;

    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) *
            sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }
  bool isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i, i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * (point.latitude - polygon[i].latitude) /
              (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude)) {
        inside = !inside;
      }
    }
    return inside;
  }

  List<LatLng> createCircle(LatLng center, double radiusMeters, int points) {
    const double degreeStep = 360 / 72;
    List<LatLng> circlePoints = [];

    for (double angle = 0; angle < 360; angle += degreeStep) {
      double angleRad = angle * pi / 180;
      double latOffset = radiusMeters / 111320 * cos(angleRad);
      double lngOffset =
          radiusMeters / (111320 * cos(center.latitude * pi / 180)) * sin(angleRad);

      circlePoints.add(LatLng(center.latitude + latOffset, center.longitude + lngOffset));
    }

    return circlePoints;
  }
  bool isBearingInRange(double bearing, double min, double max) {
    if (min <= max) {
      return bearing >= min && bearing <= max;
    } else {
      return bearing >= min || bearing <= max;
    }
  }
  List<LatLng> createOpenSector(LatLng center, LatLng miqat, double radiusMeters) {
    const double sectorAngle = 60;
    List<LatLng> sectorPoints = [];

    double bearing = calculateBearing(center, miqat);

    for (double angle = -sectorAngle; angle <= sectorAngle; angle += 5) {
      double angleRad = (bearing + angle) * pi / 180;
      double latOffset = radiusMeters / 111320 * cos(angleRad);
      double lngOffset =
          radiusMeters / (111320 * cos(center.latitude * pi / 180)) * sin(angleRad);

      sectorPoints.add(LatLng(center.latitude + latOffset, center.longitude + lngOffset));
    }

    return sectorPoints;
  }
  double calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dlon = lon2 - lon1;
    double y = sin(dlon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon);
    double bearing = atan2(y, x);

    return (bearing * 180 / pi + 360) % 360;
  }

  void _showApproachNotification() {
    startAlarm();
    _showAlertDialog("Approaching Miqat", "You are 5 minutes away from the Miqat. Get ready to enter Ihram.");
  }

  void _showInsideMiqatNotification() {
    startAlarm();
    showWindowsNotification(context);
  }

  void _showExitWarningNotification() {
    startAlarm();
    _showAlertDialog("Miqat Passed", "You exited the Miqat without starting Ihram. Please return and start your Ihram.");
  }

  void _showAlertDialog(String title, String content) {
    windowManager.show();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _stopAlarm();
                windowManager.destroy();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void startAlarm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('alarm2.mp3'));
      setState(() => _isPlaying = true);
    } catch (e) {
      print("Error playing alarm: $e");
    }
  }

  Future<void> _stopAlarm() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  void showWindowsNotification(BuildContext context) {
    windowManager.show();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Miqat Alert"),
          content: Text("You are inside the Miqat ring. Do you want to start Ihram?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _stopAlarm();
                windowManager.destroy();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IhramTutorialPage()),
                );
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                debugPrint("Skip button clicked");
                _stopAlarm();
              },
              child: Text("Skip"),
            ),
          ],
        );
      },
    );
  }
}