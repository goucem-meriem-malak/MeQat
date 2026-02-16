import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/local/shared_pref.dart';
import '../../data/services/data_provider.dart';
import '../../data/services/firebase_service.dart';
import '../../l10n/app_localizations.dart';
import '../helpers/ui_functions.dart';
import 'ihram.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showPolygons = false;
  bool showMiqatMarkers = false;
  bool isWindowNotificationShowing = false;
  bool userIn=false, userWasIn=false, ihram=false, approach=false, wait=false, exited=false, warned=false;
  bool seenInsideNotif = false, seenApproachNotif = false, seenExitingNotif=false, seenWarningNotif=false;
  int currentMiqatIndex = 0, lastPosition = -1, currentPosition = -1;
  int? lastMiqatIndex;
  bool nearLaststate = false;

  Marker? selectedMarker;

  Set<Polygon> miqatRectangles = {};
  Set<Marker> markers = {};
  Set<Marker> selectedMarkers = {};
  Set<Polygon> annulus = {};
  Set<Polygon> polygons = {};
  Set<Polyline> miqatLines = {};

  Timer? _locationTimer;

  late GoogleMapController mapController;
  final LatLng makkahLocation = LatLng(21.422487, 39.826206);
  int _selectedSayingIndex = 2;
  final DraggableScrollableController _scrollController = DraggableScrollableController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  LatLng userLocation = LatLng(26.667018, 39.654531);
  bool nearCurrentState = false;
  bool firstTime=true;
  bool auto = true;

  late List<Map<String, dynamic>> miqatData;
  late List<String> _sayingDescriptions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    miqatData = Other.miqatData(context);
    _sayingDescriptions = Other.sayingDescriptions(context);
    Future.delayed(Duration.zero, () {
      _getCurrentLocation();
      startLocationMonitoring();
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _selectedSayingIndex = 2;
      showSaying(2);
    });
  }


  Future<void> getData() async {
    ihram = await SharedPref().getIhramStatus();
    firstTime = await SharedPref().getFirstTime();

    if (firstTime == true) {
      await SharedPref().saveFirstTime(false);
      await _showLocationDialog();
    } else {
      auto = await SharedPref().getAuto();
      if (auto == true) {
        _getCurrentLocation();
      }
      startLocationMonitoring();
    }
  }

  @override
  void dispose() {
    _stopAlarm();
    _audioPlayer.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  void resetMap() {
    setState(() {
      annulus.clear();
      polygons.clear();
      miqatLines.clear();
      miqatRectangles.clear();
      showPolygons = false;
      showMiqatMarkers = false;

      userIn = false;
      userWasIn = false;
      wait = false;
      warned = false;
      exited = false;
      approach = false;

      seenApproachNotif = false;
      seenInsideNotif = false;
      seenWarningNotif = false;
      seenExitingNotif = false;
    });
  }

  Future<void> showLocationDialog(BuildContext context, bool auto) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.allow_allocation_access),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                auto ? Icons.gps_fixed : Icons.pan_tool_alt,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                auto
                    ? AppLocalizations.of(context)!.we_will_use_gps
                    : AppLocalizations.of(context)!.tap_on_map_to_get_location,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLocationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.allow_allocation_access),
        content: Text(AppLocalizations.of(context)!.allow_allocation_access_text),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => auto = true);
              await SharedPref().saveAuto(auto);
              _getCurrentLocation();
              startLocationMonitoring();
            },
            child: Text(AppLocalizations.of(context)!.auto_detect),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              auto = false;
              await SharedPref().saveAuto(auto);
              startLocationMonitoring();
            },
            child: Text(AppLocalizations.of(context)!.select_manually),
          ),
        ],
      ),
    );
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
            onTap: (LatLng latLng) async {
              setState(() {
                if(auto==false){
                  userLocation = latLng;
                  selectedMarker = Marker(
                    markerId: MarkerId("userSelected"),
                    position: latLng,
                    infoWindow: InfoWindow(title: "Your Selected Location"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  );
                }
              });
              await UpdateFirebase().updateUserLocation(userLocation);
              startLocationMonitoring();
            },
            markers: {
              if (selectedMarker != null) selectedMarker!,
              Marker(
                markerId: MarkerId(AppLocalizations.of(context)!.makkah),
                position: makkahLocation,
                infoWindow: InfoWindow(title: AppLocalizations.of(context)!.makkah),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
              ),
              Marker(
                markerId: MarkerId(AppLocalizations.of(context)!.your_location),
                position: userLocation,
                infoWindow: InfoWindow(title: AppLocalizations.of(context)!.your_location),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
              ...selectedMarkers,
            },
            polygons: {
              ...annulus,
              ...polygons,
              ...miqatRectangles,
            },
            polylines: miqatLines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          Positioned(
            top: 40,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.deepPurple.withOpacity(0.6),
              child: Icon(
                auto ? Icons.gps_fixed : Icons.pan_tool,
                color: Colors.white,
              ),
              onPressed: () async {
                bool newAuto = !auto; // toggled state
                await showLocationDialog(context, newAuto);

                setState(() {
                  auto = newAuto;
                  if (auto) {
                    _getCurrentLocation();
                    startLocationMonitoring();
                  } else {
                    startLocationMonitoring();
                    selectedMarker = null;
                  }
                });
                await SharedPref().saveAuto(auto);
              },
            ),
          ),
          DraggableScrollableSheet(
            controller: _scrollController,
            expand: true,
            initialChildSize: 0.16,
            minChildSize: 0.12,
            maxChildSize: 0.3,
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

                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) => true, // absorb
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            5,
                                (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedSayingIndex == index ? Colors.deepPurple : Colors.deepPurple.withOpacity(0.3),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedSayingIndex = index;
                                  });
                                  showSaying(index);
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.saying_number((index + 1)),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// **Show Description Instead of Grid**
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: ClampingScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _sayingDescriptions[_selectedSayingIndex],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () async {
                                final Uri pdfUrl = Uri.parse(
                                  'https://drive.google.com/file/d/1HLpKrr0ZKi2das5H0zyUcUCmBWLqEuBX/view?usp=drive_link', // your PDF link
                                );

                                if (await canLaunchUrl(pdfUrl)) {
                                  await launchUrl(
                                    pdfUrl,
                                    mode: LaunchMode.externalApplication, // opens in browser or PDF viewer
                                  );
                                } else {
                                  throw 'Could not launch $pdfUrl';
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.learn_more,
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
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
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 2),
    );
  }

  Future<void> startLocationMonitoring() async {
    if (_locationTimer?.isActive ?? false) return;

    _locationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkUserPosition(_selectedSayingIndex);
        });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.location_services_disabled),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.open_settings,
            onPressed: () async {
              await Geolocator.openLocationSettings();
            },
          ),
        ),
      );
      // Optionally auto-open settings directly without waiting for user tap:
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            AppLocalizations.of(context)!.location_permissions_denied,
          )),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          AppLocalizations.of(context)!.location_permissions_permanently_denied,
        )),
      );
      return;
    }

    // Now location services are on and permission is granted
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });

    await UpdateFirebase().updateUserLocation(userLocation);
  }

  void _onSayingPressed(int index) {
    setState(() {
      userIn = false;
      userWasIn = false;
      wait = false;
      warned = false;
      exited = false;
      approach = false;

      seenApproachNotif = false;
      seenInsideNotif = false;
      seenWarningNotif = false;
      seenExitingNotif = false;

      _selectedSayingIndex = index;
      _sayingDescriptions[index];
    });
    _scrollController.animateTo(
      0.3,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  void showSaying(int index){
    switch (index) {
      case 0:
        showSaying1();
        break;
      case 1:
        showSaying2();
        break;
      case 2:
        showSaying3();
        break;
      case 3:
        showSaying4();
        break;
      case 4:
        showSaying4();
        break;
    }
    _onSayingPressed(index);
    _sayingDescriptions[index];
    checkUserPosition(index);
  }

  void showSaying1() {
    resetMap();
    setState(() {
      showPolygons = false;

      for (var miqat in miqatData) {
        LatLng center = miqat["center"];
        LatLng closest = miqat["closest"];
        LatLng farthest = miqat["farthest"];

        double innerRadius = calculateDistance4(makkahLocation, closest);
        double outerRadius = calculateDistance4(makkahLocation, farthest);

        List<LatLng> outerCircle = createCircle(makkahLocation, outerRadius, 72);
        List<LatLng> innerCircle = createCircle(makkahLocation, innerRadius, 72);


        annulus.add(Polygon(
          polygonId: PolygonId(
            AppLocalizations.of(context)!.polygon_annulus_id(miqat["name"]),
          ),

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
      miqatData[0]["farthest"],
      miqatData[1]["farthest"],
      miqatData[2]["farthest"],
      miqatData[4]["farthest"],
      miqatData[3]["farthest"],
      miqatData[0]["farthest"]
    ];
    List<LatLng> innerPoints = [
      miqatData[0]["closest"],
      miqatData[1]["closest"],
      miqatData[2]["closest"],
      miqatData[4]["closest"],
      miqatData[3]["closest"],
      miqatData[0]["closest"]
    ];

    setState(() {
      polygons.clear();
      markers.clear(); // 🧼 Optional: clear previous markers
      showPolygons = true;

      // 🔵 Add blue markers for outer polygon points
      outerPoints.forEach((point) {
        markers.add(Marker(
          markerId: MarkerId("outer_${point.latitude}_${point.longitude}"),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });

      // 🟡 Add yellow markers for inner polygon points
      innerPoints.forEach((point) {
        markers.add(Marker(
          markerId: MarkerId("inner_${point.latitude}_${point.longitude}"),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ));
      });

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

      for (var miqat in miqatData) {
        LatLng center = miqat["center"];
        double innerRadius = calculateDistance4(makkahLocation, miqat["closest"]);
        double outerRadius = calculateDistance4(makkahLocation, miqat["farthest"]);

        List<LatLng> outerSector = createOpenSector(makkahLocation, center, outerRadius);
        List<LatLng> innerSector = createOpenSector(makkahLocation, center, innerRadius);

        selectedMarkers.add(Marker(
          markerId: MarkerId(miqat["name"]),
          position: center,
          infoWindow: InfoWindow(title: miqat["name"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));

        annulus.add(Polygon(
          polygonId: PolygonId(miqat["name"]),
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
    Set<Polygon> newPolygons = {};

    for (var miqat in miqatData) {
      LatLng miqatCenter = miqat["center"];
      String miqatName = miqat["name"];

      // Direction vector from miqat to Makkah
      double dx = makkahLocation.latitude - miqatCenter.latitude;
      double dy = makkahLocation.longitude - miqatCenter.longitude;
      double length = sqrt(dx * dx + dy * dy);

      double dirX = dx / length;
      double dirY = dy / length;

      // Perpendicular vector (عمودي)
      double perpX = -dirY;
      double perpY = dirX;

      // Rectangle size
      double halfWidth = 0.2;   // perpendicular size (about 5-6km)
      double halfLength = 0.05;  // along the direction to Makkah

      // Rectangle corners around the miqat point
      LatLng p1 = LatLng(
        miqatCenter.latitude + dirX * halfLength + perpX * halfWidth,
        miqatCenter.longitude + dirY * halfLength + perpY * halfWidth,
      );
      LatLng p2 = LatLng(
        miqatCenter.latitude + dirX * halfLength - perpX * halfWidth,
        miqatCenter.longitude + dirY * halfLength - perpY * halfWidth,
      );
      LatLng p3 = LatLng(
        miqatCenter.latitude - dirX * halfLength - perpX * halfWidth,
        miqatCenter.longitude - dirY * halfLength - perpY * halfWidth,
      );
      LatLng p4 = LatLng(
        miqatCenter.latitude - dirX * halfLength + perpX * halfWidth,
        miqatCenter.longitude - dirY * halfLength + perpY * halfWidth,
      );

      newPolygons.add(Polygon(
        polygonId: PolygonId(miqatName),
        points: [p1, p2, p3, p4],
        fillColor: Colors.blue.withOpacity(0.3),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));
    }

    setState(() {
      miqatRectangles.clear();
      miqatRectangles.addAll(newPolygons);
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 6),
    );
  }

  void checkUserPosition(int index){
    switch (index) {
      case 0:
        handleUserPosition(
          checkPositionFn: checkIfUserPositionSaying1,
          checkNearFn: checkIfUserNearSaying1,
        );
        break;
      case 1:
        handleUserPositionSaying2();
        break;
      case 2:
        handleUserPosition(
          checkPositionFn: checkIfUserPositionSaying3,
          checkNearFn: checkIfUserNearSaying3,
        );
        break;
      case 3:
        handleUserPosition(
          checkPositionFn: checkIfUserPositionSaying4,
          checkNearFn: checkIfUserNearSaying4,
        );
        break;
      case 4:
        handleUserPosition(
          checkPositionFn: checkIfUserPositionSaying5,
          checkNearFn: checkIfUserNearSaying5,
        );
        break;
    }
  }

  void handleUserPosition({
    required int Function() checkPositionFn,
    required bool Function() checkNearFn,
  }) {
    currentPosition = checkPositionFn();
    if (!ihram) nearCurrentState = checkNearFn();

    bool positionChanged = (currentPosition != lastPosition);
    bool nearChanged = (nearLaststate != nearCurrentState);

    if (positionChanged || nearChanged) {
      if (ihram) {
        if (currentPosition == 0) {
          if (seenInsideNotif) return;

          setState(() {
            userIn = true;
            exited = false;
            lastMiqatIndex = currentMiqatIndex;
          });

          _showInsideMiqatIhramNotification();
        } else {
          if (seenExitingNotif) return;

          setState(() {
            userIn = false;
            exited = true;
          });

          _showExitingMiqatNotification();
        }
      } else {
        if (currentPosition == 0) {
          if (seenInsideNotif) return;

          setState(() {
            userIn = true;
            userWasIn = true;
            approach = false;
            warned = false;
            exited = false;
            lastMiqatIndex = currentMiqatIndex;
          });
          _showInsideMiqatNotification();
        } else {
          setState(() {
            userIn = false;
          });

          if (userWasIn) {
            if (isSameMiqat()) {
              if(_selectedSayingIndex==3){
                if(wait){
                  if (seenExitingNotif) return;
                  setState(() {
                    exited = true;
                  });
                  _showExitingMiqatNotification();
                } else {
                  if (seenWarningNotif) return;
                  setState(() {
                    warned = true;
                  });
                  _showIhramViolationWarning();
                }
              } else {
                if (!wait && currentPosition == 1) {
                  if (seenWarningNotif) return;
                  setState(() {
                    warned = true;
                  });
                  _showIhramViolationWarning();
                }

                if ((!wait && currentPosition ==-1) || (currentPosition ==1 && wait)) {
                  if (seenExitingNotif) return;

                  setState(() {
                    exited = true;
                  });

                  _showExitingMiqatNotification();
                }

              }

            } else {
              if (wait) {
                if (seenApproachNotif) return;

                if (nearCurrentState) {
                  setState(() {
                    approach = true;
                    userWasIn = false;
                    wait = false;
                    exited = false;
                  });

                  _showApproachMiqatNotification();
                }

              } else {
                if(_selectedSayingIndex==3){
                  if (seenApproachNotif) return;

                  setState(() {
                    approach = true;
                    warned = false;
                  });

                  _showApproachMiqatNotification();
                } else {
                  if (seenWarningNotif) return;

                  setState(() {
                    approach = false;
                    warned = true;
                  });

                  _showIhramViolationWarning();
                }
              }
            }

          } else {
            if (seenApproachNotif) return;

            if (nearCurrentState) {
              setState(() {
                approach = true;
              });

              _showApproachMiqatNotification();
            }
          }
        }
      }

      lastPosition = currentPosition;
      nearLaststate = nearCurrentState;

    } else {
      Future.delayed(const Duration(seconds: 10), () {
        handleUserPosition(
          checkPositionFn: checkPositionFn,
          checkNearFn: checkNearFn,
        );
      });
    }
  }
  void handleUserPositionSaying2(){
    currentPosition = checkIfUserPositionSaying2();
    nearCurrentState = checkIfUserNearSaying2();

    if((currentPosition != lastPosition)||(nearLaststate!=nearCurrentState)){
      if(currentPosition == 0){
        if (seenInsideNotif || userIn) return;
        setState(() {
          userIn = true;
          userWasIn = true;
          warned = false;
          exited = false;
        });
        if(ihram){
          _showInsideMiqatIhramNotification();
        } else _showInsideMiqatNotification();
      } else {
        setState(() {
          userIn = false;
        });
        if (!userWasIn) {
          if (seenApproachNotif) return;
          if (checkIfUserNearSaying2()) {
            setState(() {
              approach = true;
            });
            _showApproachMiqatNotification();
          }
        } else {
          if(!ihram){
            if (currentPosition == -1) {
              if (seenExitingNotif) return;
              setState(() {
                exited = true;
              });
              _showExitingMiqatNotification();
            } if (currentPosition == 1) {
              setState(() {
                warned = true;
              });
              _showIhramViolationWarning();
            }
          } else {
            if (seenExitingNotif) return;
            setState(() {
              exited = true;
            });
            _showExitingMiqatNotification();
          }
        }
      }
      lastPosition = currentPosition;
      nearLaststate = nearCurrentState;
    } else if (currentPosition == lastPosition){
      Future.delayed(Duration(seconds: 10), () {
        handleUserPositionSaying2();
      });
    }
  }

  int checkIfUserPositionSaying1(){
    double userDistance = calculateDistance4(makkahLocation, userLocation);
    int closestIndex = findClosestMiqatIndex(userLocation);
    var miqat = miqatData[closestIndex];

    double innerRadius = calculateDistance4(makkahLocation, miqat["closest"]);
    double outerRadius = calculateDistance4(makkahLocation, miqat["farthest"]);

    if((userDistance > outerRadius)){
      return -1;
    } else if (userDistance < innerRadius){
      return 1;
    } else if (userDistance <= outerRadius && userDistance>= innerRadius){
      return 0;
    }
    return lastPosition;
  }
  int checkIfUserPositionSaying2() {
    List<LatLng> outerPoints = [
      miqatData[0]["farthest"],
      miqatData[1]["farthest"],
      miqatData[2]["farthest"],
      miqatData[4]["farthest"],
      miqatData[3]["farthest"],
    ];

    List<LatLng> innerPoints = [
      miqatData[0]["closest"],
      miqatData[1]["closest"],
      miqatData[2]["closest"],
      miqatData[4]["closest"],
      miqatData[3]["closest"],
    ];

    bool insideOuter = isPointInPolygonn(userLocation, outerPoints);
    bool insideInner = isPointInPolygonn(userLocation, innerPoints);

    if (insideInner) {
      return 1;
    } else if (insideOuter) {
      return 0;
    } else {
      return -1;
    }
  }
  int checkIfUserPositionSaying3(){
    double userDistance = calculateDistance4(makkahLocation, userLocation);

    int closestIndex = findClosestMiqatIndex(userLocation);
    var miqat = miqatData[closestIndex];

    double innerRadius = calculateDistance4(makkahLocation, miqat["closest"]);
    double outerRadius = calculateDistance4(makkahLocation, miqat["farthest"]);
    if((userDistance > outerRadius)){
      return -1;
    } else if (userDistance <= innerRadius){
      return 1;
    } else if (userDistance <= outerRadius && userDistance> innerRadius){
      double userBearing = calculateBearing(makkahLocation, userLocation);
      double miqatBearing = calculateBearing(makkahLocation, miqat["closest"]);

      double minAngle = (miqatBearing - 40) % 360;
      double maxAngle = (miqatBearing + 40) % 360;

      bool inSector = isBearingInRange(userBearing, minAngle, maxAngle);

      if (inSector) {
        return 0;
      }
    }
    return -1;
  }
  int checkIfUserPositionSaying4() {
    for (var miqat in miqatData) {
      LatLng miqatCenter = miqat["center"];

      // Direction vector to Makkah
      double dx = makkahLocation.latitude - miqatCenter.latitude;
      double dy = makkahLocation.longitude - miqatCenter.longitude;
      double length = sqrt(dx * dx + dy * dy);

      double dirX = dx / length;
      double dirY = dy / length;

      double perpX = -dirY;
      double perpY = dirX;

      // Same rectangle size
      double halfWidth = 0.2;
      double halfLength = 0.05;

      LatLng p1 = LatLng(
        miqatCenter.latitude + dirX * halfLength + perpX * halfWidth,
        miqatCenter.longitude + dirY * halfLength + perpY * halfWidth,
      );
      LatLng p2 = LatLng(
        miqatCenter.latitude + dirX * halfLength - perpX * halfWidth,
        miqatCenter.longitude + dirY * halfLength - perpY * halfWidth,
      );
      LatLng p3 = LatLng(
        miqatCenter.latitude - dirX * halfLength - perpX * halfWidth,
        miqatCenter.longitude - dirY * halfLength - perpY * halfWidth,
      );
      LatLng p4 = LatLng(
        miqatCenter.latitude - dirX * halfLength + perpX * halfWidth,
        miqatCenter.longitude - dirY * halfLength + perpY * halfWidth,
      );

      List<LatLng> polygon = [p1, p2, p3, p4];

      if (isPointInPolygon(userLocation, polygon)) {
        return 0; // ✅ Inside one of the rectangles
      }
    }

    return -1;
  }
  int checkIfUserPositionSaying5(){double userDistanceToMiqatLine = _calculateDistance(userLocation, miqatLines.first.points.first);
    if (userDistanceToMiqatLine <= 1000) {
      return 0;
    } else if ( userDistanceToMiqatLine >1000){
      return -1;
    } else return 1;
  }

  bool checkIfUserNearSaying1(){
    double userDistance = calculateDistance4(makkahLocation, userLocation);

    if (userDistance <= 2000) {
      return true;
    }
    return false;
  }
  bool checkIfUserNearSaying2() {
    int currentPosition = checkIfUserPositionSaying2();

    List<LatLng> outerPoints = [
      miqatData[0]["farthest"],
      miqatData[1]["farthest"],
      miqatData[2]["farthest"],
      miqatData[4]["farthest"],
      miqatData[3]["farthest"],
      miqatData[0]["farthest"]
    ];
    List<LatLng> innerPoints = [
      miqatData[0]["closest"],
      miqatData[1]["closest"],
      miqatData[2]["closest"],
      miqatData[4]["closest"],
      miqatData[3]["closest"],
      miqatData[0]["closest"]
    ];
    double distanceToOuter = distanceToPolygonEdge(userLocation, outerPoints);
    double distanceToInner = distanceToPolygonEdge(userLocation, innerPoints);

    if ((currentPosition == -1 || currentPosition == 1) && (distanceToOuter <= 2000 || distanceToInner <= 2000)) {
      return true;
    }

    return false;
  }
  bool checkIfUserNearSaying3() {
    double userDistance = calculateDistance4(makkahLocation, userLocation);
    int closestIndex = findClosestMiqatIndex(userLocation);
    var miqat = miqatData[closestIndex];

    double outerRadius = calculateDistance4(makkahLocation, miqat["farthest"]);

    if (userDistance <= outerRadius + 10000 && userDistance >= outerRadius - 10000) {
      double userBearing = calculateBearing(makkahLocation, userLocation);
      double miqatBearing = calculateBearing(makkahLocation, miqat["closest"]);

      double minAngle = (miqatBearing - 40 + 360) % 360;
      double maxAngle = (miqatBearing + 40) % 360;

      bool inSector = isBearingInRange(userBearing, minAngle, maxAngle);


      if (inSector) {
        return true;
      }
    }
    return false;
  }
  bool checkIfUserNearSaying4() {
    for (var miqat in miqatData) {
      LatLng miqatCenter = miqat["center"];

      // Direction vector to Makkah
      double dx = makkahLocation.latitude - miqatCenter.latitude;
      double dy = makkahLocation.longitude - miqatCenter.longitude;
      double length = sqrt(dx * dx + dy * dy);

      double dirX = dx / length;
      double dirY = dy / length;

      // Perpendicular (عمودي)
      double perpX = -dirY;
      double perpY = dirX;

      // Rectangle size
      double halfWidth = 0.2 + 0.02;    // 0.05 normal + 0.02 buffer (~2km)
      double halfLength = 0.05 + 0.02;

      // Inflated rectangle corners
      LatLng p1 = LatLng(
        miqatCenter.latitude + dirX * halfLength + perpX * halfWidth,
        miqatCenter.longitude + dirY * halfLength + perpY * halfWidth,
      );
      LatLng p2 = LatLng(
        miqatCenter.latitude + dirX * halfLength - perpX * halfWidth,
        miqatCenter.longitude + dirY * halfLength - perpY * halfWidth,
      );
      LatLng p3 = LatLng(
        miqatCenter.latitude - dirX * halfLength - perpX * halfWidth,
        miqatCenter.longitude - dirY * halfLength - perpY * halfWidth,
      );
      LatLng p4 = LatLng(
        miqatCenter.latitude - dirX * halfLength + perpX * halfWidth,
        miqatCenter.longitude - dirY * halfLength + perpY * halfWidth,
      );

      List<LatLng> polygon = [p1, p2, p3, p4];

      if (isPointInPolygon(userLocation, polygon)) {
        return true; // ✅ User is near this miqat
      }
    }

    return false; // ❌ Not near any
  }
  bool checkIfUserNearSaying5() {

    for (var miqat in miqatData) {
      double distance = _calculateDistance(userLocation, miqat["center"]);

      if (distance <= 1000) {
        return true;
      }
    }
    return false;
  }

  double distanceToPolygonEdge(LatLng point, List<LatLng> polygon) {
    double minDistance = double.infinity;
    for (int i = 0; i < polygon.length; i++) {
      LatLng a = polygon[i];
      LatLng b = polygon[(i + 1) % polygon.length];
      double dist = distanceToSegment(point, a, b);
      if (dist < minDistance) minDistance = dist;
    }
    return minDistance;
  }
  double distanceToSegment(LatLng p, LatLng a, LatLng b) {
    double lat1 = a.latitude;
    double lon1 = a.longitude;
    double lat2 = b.latitude;
    double lon2 = b.longitude;
    double lat3 = p.latitude;
    double lon3 = p.longitude;

    double dx = lat2 - lat1;
    double dy = lon2 - lon1;
    if (dx == 0 && dy == 0) {
      return calculateDistance4(p, a);
    }

    double t = ((lat3 - lat1) * dx + (lon3 - lon1) * dy) / (dx * dx + dy * dy);
    t = max(0, min(1, t));
    LatLng projection = LatLng(lat1 + t * dx, lon1 + t * dy);
    return calculateDistance4(p, projection);
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
    const double sectorAngle = 40;
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
  bool isLastMiqat(){
    int closestMiqatIndex = 0;
    double closestDistance = double.infinity;

    for (int i = 0; i < miqatData.length; i++) {
      double distance = _calculateDistance(userLocation, miqatData[i]["center"]);
      if (distance < closestDistance) {
        closestDistance = distance;
        closestMiqatIndex = i;
      }
    }

    bool isLastMiqat = closestMiqatIndex == miqatData.length - 1;

    return isLastMiqat;
  }
  int findClosestMiqatIndex(LatLng userLocation) {
    double minDistance = double.infinity;
    int closestIndex = -1;

    for (int i = 0; i < miqatData.length; i++) {
      double distance = calculateDistance4(userLocation, miqatData[i]["center"]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }
  bool isSameMiqat(){
    currentMiqatIndex = findClosestMiqatIndex(userLocation);
    if (lastMiqatIndex == currentMiqatIndex){
      return true;
    } else {
      return false;
    }
  }
  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int i, j = polygon.length - 1;
    bool oddNodes = false;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude < point.latitude && polygon[j].latitude >= point.latitude ||
          polygon[j].latitude < point.latitude && polygon[i].latitude >= point.latitude) &&
          (polygon[i].longitude <= point.longitude || polygon[j].longitude <= point.longitude)) {
        if (polygon[i].longitude + (point.latitude - polygon[i].latitude) /
            (polygon[j].latitude - polygon[i].latitude) *
            (polygon[j].longitude - polygon[i].longitude) < point.longitude) {
          oddNodes = !oddNodes;
        }
      }
      j = i;
    }

    return oddNodes;
  }
  double calculateDistance4(LatLng p1, LatLng p2) {
    const R = 6371000; // Earth's radius in meters
    double dLat = _degToRad(p2.latitude - p1.latitude);
    double dLng = _degToRad(p2.longitude - p1.longitude);

    double a = sin(dLat/2) * sin(dLat/2) +
        cos(_degToRad(p1.latitude)) * cos(_degToRad(p2.latitude)) *
            sin(dLng/2) * sin(dLng/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));

    return R * c;
  }
  double _degToRad(double deg) => deg * pi / 180;
  bool isPointInPolygonn(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    int count = polygon.length;

    for (int i = 0; i < count; i++) {
      LatLng a = polygon[i];
      LatLng b = polygon[(i + 1) % count];

      // Check if point is between the y-values of a and b
      if ((a.latitude > point.latitude) != (b.latitude > point.latitude)) {
        double slope = (b.longitude - a.longitude) / (b.latitude - a.latitude);
        double possibleLng = slope * (point.latitude - a.latitude) + a.longitude;

        if (point.longitude < possibleLng) {
          intersections++;
        }
      }
    }

    return (intersections % 2) == 1;
  }



  void _startAlarm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('alarm1.mp3'));
    } catch (e) {
      print("Error playing alarm: $e");
    }
  }
  Future<void> _stopAlarm() async {
    await _audioPlayer.stop();
  }

  void _showApproachMiqatNotification() {
    if (isWindowNotificationShowing) return;
    isWindowNotificationShowing = true;
    if (seenApproachNotif || userIn) return;
    seenApproachNotif = true;
    seenInsideNotif = false;
    _startAlarm();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(AppLocalizations.of(context)!.approach_notif_title,),
          content: Text(AppLocalizations.of(context)!.approach_notif,),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok,),
              onPressed: () {
                _stopAlarm();
                Navigator.of(context).pop();
                isWindowNotificationShowing = false;
              },
            ),
          ],
        );
      },
    );
  }
  void _showInsideMiqatIhramNotification(){
    if (isWindowNotificationShowing) return;
    isWindowNotificationShowing = true;
    if (seenInsideNotif || !userIn) return;
    seenInsideNotif = true;
    seenExitingNotif = false;
    _startAlarm();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(AppLocalizations.of(context)!.inside_notif_title,),
          content: Text(AppLocalizations.of(context)!.inside_notif,),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok),
              onPressed: () {
                _stopAlarm();
                Navigator.of(context).pop();
                isWindowNotificationShowing = false;
              },
            ),
          ],
        );
      },
    );
  }
  void _showInsideMiqatNotification() {
    if (isWindowNotificationShowing) return;
    isWindowNotificationShowing = true;
    if (seenInsideNotif || !userIn) return;
    seenInsideNotif = true;
    seenExitingNotif = false;
    seenWarningNotif = false;
    _startAlarm();

    if (_selectedSayingIndex==1){
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(AppLocalizations.of(context)!.inside_notif_title),
            content: Text(AppLocalizations.of(context)!.ihram_notif),
            actions: [
              TextButton(
                child: Text(AppLocalizations.of(context)!.yes),
                onPressed: () {
                  _stopAlarm();
                  setState(() {
                    ihram=true;
                  });
                  Navigator.of(context).pop();
                  isWindowNotificationShowing = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IhramTutorialPage()),
                  );
                },
              ),
              TextButton(
                child: Text(AppLocalizations.of(context)!.later),
                onPressed: () {
                  _stopAlarm();
                  Navigator.of(context).pop();
                  isWindowNotificationShowing = false;
                  Future.delayed(Duration(seconds: 20), () {
                    seenInsideNotif = false;
                    _showInsideMiqatNotification();
                  });
                },
              ),
            ],
          );
        },
      );
    }
    else {
      if(!warned){
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(AppLocalizations.of(context)!.inside_notif_title),
              content: Text(AppLocalizations.of(context)!.ihram_notif),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.yes),
                  onPressed: () {
                    _stopAlarm();
                    setState(() {
                      ihram=true;
                      wait = false;
                      SharedPref().saveIhramStatus(true);
                    });
                    Navigator.of(context).pop();
                    isWindowNotificationShowing = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IhramTutorialPage()),
                    );
                  },
                ),
                if (!isLastMiqat())
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.wait),
                    onPressed: () {
                      _stopAlarm();
                      setState(() {
                        wait = true;
                      });
                      Navigator.of(context).pop();
                      isWindowNotificationShowing = false;
                    },
                  ),
                TextButton(
                  child: Text(AppLocalizations.of(context)!.later),
                  onPressed: () {
                    _stopAlarm();
                    setState(() {
                      wait = false;
                    });
                    seenInsideNotif = false;
                    Navigator.of(context).pop();
                    isWindowNotificationShowing = false;
                    Future.delayed(Duration(seconds: 20), () {
                      _showInsideMiqatNotification();
                    });
                  },
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(AppLocalizations.of(context)!.back_inside_title,),
              content: Text(AppLocalizations.of(context)!.back_inside),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context)!.ok,),
                  onPressed: () {
                    _stopAlarm();
                    setState(() {
                      ihram=true;
                    });
                    Navigator.of(context).pop();
                    isWindowNotificationShowing = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IhramTutorialPage()),
                    );
                  },
                )
              ],
            );
          },
        );
      }
    }
  }
  void _showExitingMiqatNotification() {
    if (isWindowNotificationShowing) return;
    isWindowNotificationShowing = true;
    if (seenExitingNotif || userIn) return;
    seenExitingNotif = true;
    seenInsideNotif = false;
    seenApproachNotif = false;
    _startAlarm();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(AppLocalizations.of(context)!.exiting_title,),
          content: Text(AppLocalizations.of(context)!.exiting,),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok,),
              onPressed: () {
                _stopAlarm();
                Navigator.of(context).pop();
                isWindowNotificationShowing = false;
              },
            ),
          ],
        );
      },
    );
  }
  void _showIhramViolationWarning() {
    if (isWindowNotificationShowing) return;
    isWindowNotificationShowing = true;
    if (seenWarningNotif || userIn) return;
    if (_selectedSayingIndex==3) {seenApproachNotif = false;}
    seenWarningNotif = true;
    seenInsideNotif = false;

    _startAlarm();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.warning_title,),
          content: Text(AppLocalizations.of(context)!.warning,),
          actions: [
            TextButton(
              onPressed: () {
                _stopAlarm();
                Navigator.of(context).pop();
                isWindowNotificationShowing = false;
              },
              child: Text(AppLocalizations.of(context)!.ok,),
            ),
          ],
        );
      },
    );
  }
}

