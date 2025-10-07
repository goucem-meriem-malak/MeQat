import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/local/shared_pref.dart';
import '../../data/models/user.dart';
import '../../data/services/firebase_service.dart';
import '../helpers/ui_functions.dart';

class LostPage extends StatefulWidget {
  const LostPage({super.key});

  @override
  State<LostPage> createState() => _LostPageState();
}

class _LostPageState extends State<LostPage> {
  final picker = ImagePicker();
  final faceDetector = FaceDetector(options: FaceDetectorOptions());
  Interpreter? interpreter;
  String text = "";
  String? foundUserUID, currentUserId;
  double progress = 0;
  bool imgPicked = false, processed = false, found = false, processing = false;
  myUser? foundUser;
  Map<String, dynamic>? leaderInfo, foundUserInfo;
  List<Map<String, dynamic>>? membersInfo;
  bool delegation = false;
  bool leader = false;


  @override
  void initState() {
    super.initState();
    _getData();
    _loadModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      text = AppLocalizations.of(context)!.lost_1;
    });
  }
  Future<void> _getData() async {
    currentUserId = await SharedPref().getUID();
  }

  Future<void> _loadModel() async {
    print('✅ _loadModel: Loading model...');
    await loadModel();
    setState(() => progress = 0.2);
    print('✅ _loadModel: Model loaded successfully');
  }

  Future<void> loadModel() async {
    final appDir = await getApplicationDocumentsDirectory();
    print('✅ loadModel: App dir is $appDir');
    final byteData = await rootBundle.load('assets/facenet.zip');

    final zipFilePath = '${appDir.path}/facenet.zip';
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(byteData.buffer.asUint8List());


    final modelDir = Directory('${appDir.path}/facenet');

    if (!await modelDir.exists()) {
      print('✅ loadModel: Creating model directory');
      await modelDir.create(recursive: true);
    }

    final extractedModel = File('${modelDir.path}/facenet.tflite');
    if (!await extractedModel.exists()) {
      print('✅ loadModel: Extracting model from zip...');
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: modelDir,
      );
      print('✅ loadModel: Extraction done');
    } else {
      print('✅ loadModel: Model already extracted');
    }

    print('✅ loadModel: Loading interpreter from file ${extractedModel.path}');
    interpreter = await Interpreter.fromFile(extractedModel);
    print('✅ loadModel: Interpreter loaded');
  }

  Future<void> pickAndMatchFace() async {
    print('✅ pickAndMatchFace: Starting face pick');
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      processing = true;
      text = AppLocalizations.of(context)!.lost_2;
    });
    if (pickedFile == null) {
      print('❌ pickAndMatchFace: No image picked');
      setState(() {
        processing = false;
        text = AppLocalizations.of(context)!.lost_3;
      });
      return;
    }
    print('✅ pickAndMatchFace: Image picked at ${pickedFile.path}');
    final bytes = await pickedFile.readAsBytes();

    final croppedFace = await detectFaceFromBytes(bytes);
    if (croppedFace == null) {
      print('❌ pickAndMatchFace: No face detected in photo');
      setState(() {
        processing = false;
        text = AppLocalizations.of(context)!.lost_4;
        progress = 100;
        imgPicked = false;
      });
      return;
    }
    print('✅ pickAndMatchFace: Face detected and cropped');

    final userEmbedding = await getFaceEmbedding(croppedFace);
    setState(() => progress = 0.4);
    print('✅ pickAndMatchFace: User embedding extracted');

    final matchedUid = await matchUserImageWithSupabaseStorage(userEmbedding);
    print('✅ pickAndMatchFace: Match result - $matchedUid');
  }

  Future<img.Image?> detectFaceFromBytes(Uint8List imageBytes) async {
    print('✅ detectFaceFromBytes: Decoding image');
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      print('❌ detectFaceFromBytes: Failed to decode image');
      return null;
    }

    final inputImage = InputImage.fromFilePath(await writeBytesToTempFile(imageBytes));
    final faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      print('❌ detectFaceFromBytes: No faces detected');
      return null;
    }

    final face = faces.first.boundingBox;
    print('✅ detectFaceFromBytes: Face detected at $face');

    final cropRect = Rect.fromLTWH(
      max(0, face.left),
      max(0, face.top),
      min(face.width, originalImage.width - face.left),
      min(face.height, originalImage.height - face.top),
    );

    final cropped = img.copyCrop(
      originalImage,
      x: cropRect.left.toInt(),
      y: cropRect.top.toInt(),
      width: cropRect.width.toInt(),
      height: cropRect.height.toInt(),
    );

    print('✅ detectFaceFromBytes: Face cropped');
    return cropped;
  }

  Future<String> writeBytesToTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp.jpg');
    await file.writeAsBytes(bytes);
    print('✅ writeBytesToTempFile: Written bytes to ${file.path}');
    return file.path;
  }
  Future<List<double>> getFaceEmbedding(img.Image faceImage) async {
    if (interpreter == null) throw Exception('Model not loaded');

    final inputSize = 112;
    final buffer = preprocess(faceImage, inputSize);

    // Create 4D input tensor [1, 112, 112, 3]
    List<List<List<List<double>>>> input = List.generate(
      1,
          (_) => List.generate(
        inputSize,
            (_) => List.generate(
          inputSize,
              (_) => List.filled(3, 0.0),
        ),
      ),
    );

    int bufferIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        for (int c = 0; c < 3; c++) {
          input[0][y][x][c] = buffer[bufferIndex++];
        }
      }
    }

    var output = List.filled(1, List.filled(128, 0.0)); // 128 dims here

    print('✅ getFaceEmbedding: Running interpreter...');
    interpreter!.run(input, output);
    print('✅ getFaceEmbedding: Interpreter finished.');

    final embedding = List<double>.from(output[0]);
    final norm = sqrt(embedding.fold<double>(0, (p, e) => p + e * e));
    print("✅ Embedding computed.");
    return embedding.map((e) => e / norm).toList();
  }
  List<double> normalize(List<double> embedding) {
    final norm = sqrt(embedding.map((e) => e * e).reduce((a, b) => a + b));
    if (norm == 0) return embedding;
    return embedding.map((e) => e / norm).toList();
  }
  Float32List preprocess(img.Image image, int inputSize) {
    print('✅ preprocess: Resizing image to $inputSize x $inputSize');
    final resized = img.copyResize(image, width: inputSize, height: inputSize);
    final buffer = Float32List(inputSize * inputSize * 3);

    int pixelIndex = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        buffer[pixelIndex++] = (r - 127.5) / 128;
        buffer[pixelIndex++] = (g - 127.5) / 128;
        buffer[pixelIndex++] = (b - 127.5) / 128;
      }
    }
    print('✅ preprocess: Finished preprocessing');
    return buffer;
  }
  Future<String?> matchUserImageWithSupabaseStorage(List<double> userEmbedding) async {
    final normalizedInput = normalize(userEmbedding);
    print('✅ matchUserImageWithSupabaseStorage: Listing user images');
    final supabase = Supabase.instance.client;

    final response = await supabase.storage.from('users').list(path: '');

    if (response == null || response.isEmpty) {
      setState(() => progress = 0.6);  // 100%

      print('❌ matchUserImageWithSupabaseStorage: No images found or failed to list');
      return null;
    }

    for (final file in response) {
      setState(() => progress = 0.8);
      final fileName = file.name;
      final uid = fileName.split('.').first;

      print('✅ matchUserImageWithSupabaseStorage: Downloading image $fileName');
      final imageResponse = await supabase.storage.from('users').download(fileName);
      if (imageResponse == null) {
        print('❌ matchUserImageWithSupabaseStorage: Failed to download $uid');
        continue;
      }

      final bytes = imageResponse;
      final img.Image? croppedFace = await detectFaceFromBytes(bytes);
      if (croppedFace == null) {
        print('❌ matchUserImageWithSupabaseStorage: Could not detect face in $uid');
        continue;
      }

      final embedding = await getFaceEmbedding(croppedFace);

      final normalizedStored = embedding;

      final similarity = cosineSimilarity(normalizedInput, normalizedStored);


      print('✅ matchUserImageWithSupabaseStorage: Compared with $uid similarity: $similarity');

      if (similarity > 0.8) {
        print('✅ matchUserImageWithSupabaseStorage: Match found: $uid');

        foundUserInfo = await UpdateFirebase().getUserNameByUID(uid);
        foundUser = await UpdateFirebase().getLostUser(uid);
        delegation = await UpdateFirebase().isDelegationInPreferences(uid);
        if(uid== currentUserId){
          text = AppLocalizations.of(context)!.lost_5( foundUserInfo!["lastName"], foundUserInfo!["firstName"],);
        } else {
          if(delegation){
            leader = await UpdateFirebase().isLeaderInPreferences(uid);
            if(leader){
              membersInfo = await UpdateFirebase().getAllMemberInfoByLeaderUID(uid);
              text = AppLocalizations.of(context)!.lost_6( foundUserInfo!["lastName"], foundUserInfo!["firstName"],);
            } else {
              leaderInfo = await UpdateFirebase().getLeaderLocationAndName(uid);
              print("leaderinfo: ${leaderInfo!.isEmpty}");
              text = AppLocalizations.of(context)!.lost_7( foundUserInfo!["lastName"], foundUserInfo!["firstName"],);
            }
          } else {
            text = AppLocalizations.of(context)!.lost_8;
          }
        }

        setState(() {
          progress = 1;
          found = true;
          processing = false;
          foundUserUID = uid;
        });

        cleanUpResources();
        return uid;
      }
    }

    setState(() {
      text = AppLocalizations.of(context)!.lost_9;
      progress = 1;
      found = false;
      processing = false;
    });
    print('❌ matchUserImageWithSupabaseStorage: No match found');
    return null;
  }
  double cosineSimilarity(List<double> e1, List<double> e2) {
    double dot = 0;
    double normA = 0;
    double normB = 0;
    for (int i = 0; i < e1.length; i++) {
      dot += e1[i] * e2[i];
      normA += e1[i] * e1[i];
      normB += e2[i] * e2[i];
    }
    return dot / (sqrt(normA) * sqrt(normB));
  }

  Future<void> cleanUpResources() async {
    print('🧹 Cleaning up resources...');

    // Dispose interpreter if applicable
    interpreter?.close();
    interpreter = null;

    // Dispose face detector if applicable
    await faceDetector.close();
    // Reset faceDetector variable if needed
    // faceDetector = null;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp.jpg');
    if (await file.exists()) {
      await file.delete();
      print('✅ deleteTempFile: Temp file deleted');
    }
    // Clear any large buffers or cached images if stored
    // e.g., cached embeddings = null;

    print('🧹 Resources cleaned.');
  }

  @override
  void dispose() {
    print('✅ dispose: Closing face detector and interpreter');
    cleanUpResources();
    faceDetector.close();
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.face_verification), centerTitle: true,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(flex: 2),
                Container(
                  alignment: Alignment.topCenter,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,  // centers text horizontally inside the container
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                if (!found && !processing) ...[
                  const SizedBox(height: 20),
                  UIFunctions().buildRoundedButton(
                    title: AppLocalizations.of(context)!.take_pic_verify,
                    onPressed: pickAndMatchFace,
                  )
                ],
                if (found && currentUserId!=foundUserUID) ...[
                  const SizedBox(height: 20),
                  UIFunctions().buildRoundedButton(
                    title: AppLocalizations.of(context)!.find_delegation,
                    onPressed: () async {
                      if (!leader && leaderInfo != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserLocationMap(leaderInfo: leaderInfo),
                          ),
                        );
                      } else if (leader && membersInfo != null && membersInfo!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserLocationMap(membersInfo: membersInfo),
                          ),
                        );
                      }
                    },
                  ),
                ],
                if (processing) ...[
                  if (progress > 0 && progress < 1.0) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),  // rounded corners
                      child: Container(
                        height: 12,  // thicker progress bar
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,  // track color (background)
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            // gradient-like effect using a solid color here; you can customize with shaders for gradients if needed
                            Colors.deepPurpleAccent.shade400,
                          ),
                          minHeight: 12,
                        ),
                      ),
                    ),
                  ],
                ],
                const Spacer(flex: 2),
              ],
          ),
        ),
      ),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
    );
  }
}

class UserLocationMap extends StatefulWidget {
  final Map<String, dynamic>? leaderInfo;
  final List<Map<String, dynamic>> ? membersInfo;

  const UserLocationMap({
    super.key,
    this.leaderInfo,
    this.membersInfo,
  });

  @override
  State<UserLocationMap> createState() => _UserLocationMapState();
}

class _UserLocationMapState extends State<UserLocationMap> {
  LatLng? userLocation;
  LatLng? leaderLocation;
  String leaderFullName = '';

  GoogleMapController? _mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();

    if (widget.leaderInfo != null) {
      final loc = widget.leaderInfo!['location'];

      if (loc != null && loc is GeoPoint) {
        leaderLocation = LatLng(loc.latitude, loc.longitude);
        leaderFullName = "${widget.leaderInfo!['firstName'] ?? ''} ${widget.leaderInfo!['lastName'] ?? ''}".trim();
      }
    }

    setState(() {
      
    });
    _setupMarkers();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar(AppLocalizations.of(context)!.location_services_disabled);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar(AppLocalizations.of(context)!.location_permissions_denied);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar(AppLocalizations.of(context)!.location_permissions_permanently_denied);
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });

    await UpdateFirebase().updateUserLocation(userLocation!);

    setState(() {

    });
    _setupMarkers();
  }

  void _setupMarkers() {
    Set<Marker> newMarkers = {};

    if (userLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('userLocation'),
          position: userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    if (widget.leaderInfo != null && leaderLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('leaderLocation'),
          position: leaderLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: leaderFullName.isNotEmpty ? leaderFullName : 'Leader'),
        ),
      );
    } else if (widget.membersInfo != null) {
      for (var member in widget.membersInfo!) {
        final loc = member['location'];
        if (loc != null && loc['latitude'] != null && loc['longitude'] != null) {
          LatLng memberLocation = LatLng(loc['latitude'], loc['longitude']);
          String fullName = "${member['firstName'] ?? ''} ${member['lastName'] ?? ''}".trim();
          newMarkers.add(
            Marker(
              markerId: MarkerId(member['uid'] ?? UniqueKey().toString()),
              position: memberLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: fullName),
            ),
          );
        }
      }
    }

    setState(() {
      markers = newMarkers;
    });

    _fitBounds();
  }

  void _fitBounds() {
    if (_mapController == null || markers.isEmpty) return;

    LatLngBounds? bounds;

    for (var marker in markers) {
      if (bounds == null) {
        bounds = LatLngBounds(
          southwest: marker.position,
          northeast: marker.position,
        );
      } else {
        bounds = LatLngBounds(
          southwest: LatLng(
            _min(bounds.southwest.latitude, marker.position.latitude),
            _min(bounds.southwest.longitude, marker.position.longitude),
          ),
          northeast: LatLng(
            _max(bounds.northeast.latitude, marker.position.latitude),
            _max(bounds.northeast.longitude, marker.position.longitude),
          ),
        );
      }
    }

    if (bounds != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds!, 80));
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Location Map')),
      bottomNavigationBar: UIFunctions().buildBottomNavBar(context, 0),
      body: userLocation == null && leaderLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: userLocation!,
          zoom: 14,
        ),
        markers: markers,
        onMapCreated: (controller) {
          _mapController = controller;
          _fitBounds();
        },
      ),
    );
  }
}

