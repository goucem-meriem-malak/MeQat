import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meqat/Profile.dart';
import 'package:meqat/home.dart';
import 'package:meqat/ihram.dart';
import 'package:meqat/premium.dart';
import 'package:meqat/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import '../Data.dart';
import '../menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showPolygons = false;
  bool alarmPlaying = false;
  bool userDecisionMade = false;
  bool insideMiqatRing = false;
  bool _isPlaying = false;
  bool showMiqatMarkers = false;

  Set<Marker> selectedMarkers = {};
  Marker? selectedMarker;
  Set<Polygon> annulus = {};
  Set<Polygon> polygons = {};
  Set<Polyline> miqatLines = {};
  Set<Polyline> Lines = {};

  int _locationIndex = 0;
  Timer? _locationTimer;

  late GoogleMapController mapController;
  final LatLng makkahLocation = LatLng(21.422487, 39.826206);
  int? _selectedSayingIndex = null;
  double _currentChildSize = 0.1;
  List<String> _sayingDescriptions = [
    "Is not approved by any madhhab",  // Saying 1
    "Is not approved by any madhhab",  // Saying 2
    "Saying 3 is approved by all 4 madhhabs",  // Saying 3
    "Description for Saying 4",  // Saying 4
    "Only approved by madhhab Hanbali",  // Saying 5
  ];
  final DraggableScrollableController _scrollController = DraggableScrollableController();

  final AudioPlayer _audioPlayer = AudioPlayer();

  //LatLng? userLocation = null;
  LatLng userLocation = LatLng(21.875126, 40.464549);
  //LatLng? userLocation = null;
  List<Map<String, double>> mockLocations = [
    {"lat": 19.980817, "lng": 42.595958}, // Location 1
    {"lat": 24.429102, "lng": 39.585716},   // Location 2
    {"lat": 24.422534, "lng": 39.583691},
    {"lat": 24.358981, "lng": 39.614368},// Location 3
  ];

  void _startMockLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      final location = mockLocations[_locationIndex];
      double lat = location['lat']!;
      double lng = location['lng']!;

      print("Simulated Location: $lat, $lng");

      // Update the global user location (assuming you have this variable)
      userLocation = {"lat": lat, "lng": lng} as LatLng;

      // Now test the proximity notification
      await checkNotifyFiveMinutesBeforeMiqat();

      _locationIndex = (_locationIndex + 1) % mockLocations.length;
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, () {
        //_getCurrentLocation();
        _startMockLocationUpdates();

      });
      _selectedSayingIndex = 2;
      showSaying(2);
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero, () {
      //_getCurrentLocation();
      _startMockLocationUpdates();
    });
  }

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

    userLocation = LatLng(position.latitude, position.longitude);
    await handlelocation(userLocation);
    setState(() {});
  }



  Future<void> checkNotifyFiveMinutesBeforeMiqat() async {
    const double walkingSpeed = 1.4; // meters per second (average human walking speed)
    const double drivingSpeed = 22.22; // meters per second (80km/h average car speed)

    double userDistanceToClosestMiqat = double.infinity;

    for (var miqat in miqatData) {
      double distanceToClosest = _calculateDistance(userLocation, miqat["closest"]);
      double distanceToFarthest = _calculateDistance(userLocation, miqat["farthest"]);

      double distance = distanceToClosest < distanceToFarthest ? distanceToClosest : distanceToFarthest;

      if (distance < userDistanceToClosestMiqat) {
        userDistanceToClosestMiqat = distance;
      }
    }

    // Estimate arrival time (assuming driving)
    double estimatedSecondsToReach = userDistanceToClosestMiqat / drivingSpeed;
    double estimatedMinutesToReach = estimatedSecondsToReach / 60;

    if (estimatedMinutesToReach <= 5) {
      if (!alarmPlaying) {
        startAlarm();
        showWindowsNotification(context);
      }
    }
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
    if(userLocation!=null){
      checkNotifyFiveMinutesBeforeMiqat();
    }
    _sayingDescriptions[index];
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
        points: [userLocation, makkahLocation],
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


  void checkUserLocationSaying1() {
    if (userDecisionMade) return;
    double userDistance = calculateDistance(makkahLocation, userLocation);
    bool currentlyInsideMiqat = false;

    for (var miqat in miqatData) {
      double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
      double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

      if (userDistance <= outerRadius){

        currentlyInsideMiqat = true;

        if (!insideMiqatRing) {
          if (!alarmPlaying) {
            startAlarm();
          }

          setState(() {
            insideMiqatRing = true;
          });

          showWindowsNotification(context);
        }

        break;
      }
    }

    if (!currentlyInsideMiqat && insideMiqatRing) {
      Fluttertoast.showToast(
          msg: "You exited the Miqat ring. If needed, re-enter to start Ihram!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3
      );

      setState(() {
        insideMiqatRing = false;
      });
    }


    if (!userDecisionMade) {
      Future.delayed(Duration(seconds: 3), () {
        checkUserLocationSaying1();
      });
    }
  }
  void checkUserLocationSaying2() {
    List<LatLng> outerPoints = miqatData.map((e) => e["farthest"] as LatLng).toList();
    List<LatLng> innerPoints = miqatData.map((e) => e["closest"] as LatLng).toList();

    bool insideOuter = isPointInsidePolygon(userLocation, outerPoints);
    bool insideInner = isPointInsidePolygon(userLocation, innerPoints);
    bool insideZone = insideOuter;

    if (insideZone && !alarmPlaying) {
      startAlarm();
      showWindowsNotification(context);
    }
  }
  void checkUserLocationSaying3() {
    if (insideMiqatRing || userDecisionMade) return;

    double userDistance = calculateDistance(makkahLocation, userLocation);

    for (var miqat in miqatData) {
      double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
      double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

      if (userDistance <= outerRadius) {
        double userBearing = calculateBearing(makkahLocation, userLocation);
        double miqatBearing = calculateBearing(makkahLocation, miqat["closest"]);

        double minAngle = (miqatBearing - 60) % 360;
        double maxAngle = (miqatBearing + 60) % 360;

        bool inSector = isBearingInRange(userBearing, minAngle, maxAngle);

        if (inSector) {
          if (!alarmPlaying) {
            startAlarm();
          }

          Fluttertoast.showToast(
              msg: "You are inside the Miqat ring and in the Ihram sector!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3
          );

          setState(() {
            insideMiqatRing = true;
          });

          showWindowsNotification(context);
          break;
        }
      }
    }

    if (!insideMiqatRing && !userDecisionMade) {
      Future.delayed(Duration(seconds: 3), () {
        checkUserLocationSaying3();
      });
    }
  }
  void checkUserLocationSaying4() {
    for (var miqat in miqatData) {
      double distance = _calculateDistance(userLocation, miqat["center"]);
      if (distance <= 1000) {
        startAlarm();
        break;
      }
    }
  }
  void checkUserLocationSaying5() {
    double userDistanceToMiqatLine = _calculateDistance(userLocation, miqatLines.first.points.first);
    if (userDistanceToMiqatLine <= 1000) {
      showWindowsNotification(context);
      startAlarm();
    }
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
                position: userLocation,
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
              UI().buildNavItem(Icons.menu, "Menu", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPage()));
              }, false),

              UI().buildNavItem(Icons.search, "Search", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
              }, false),

              UI().buildNavItem(Icons.home, "Home", () {
              }, true),

              UI().buildNavItem(Icons.star, "Premium", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumPage()));
              }, false),

              UI().buildNavItem(Icons.settings, "Profile", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => profilePage()));
              }, false), // Profile is selected
            ],
          ),
        ),
      ),
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    _locationTimer?.cancel();
    super.dispose();
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

  Future<void> handlelocation(userLocation) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print("❌ No internet connection.");
      return;
    } else {

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) {
        print("❌ UID not found in SharedPreferences.");
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'location': GeoPoint(userLocation.latitude, userLocation.longitude),
        'lastUpdatedLocation': FieldValue.serverTimestamp(),
      });



      print("✅ Location updated for user: $uid");
    }
  }
}