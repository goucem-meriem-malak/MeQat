import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:meqat/home.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRPage extends StatefulWidget {
  final bool isLeader;

  QRPage({required this.isLeader});

  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final Color primaryColor = Color(0xFF2D2D2D);
  final Color background = Color(0xFFF8F5F0);
  final qrKey = GlobalKey(debugLabel: 'qr');
  String? qrId;
  QRViewController? qrController;

  bool showCheckmark = false;

  List<String> _memberNames = [];
  bool _isLoadingMembers = true;
  bool _noInternet = false;

  @override
  void initState() {
    super.initState();
    _generateAndSaveQRId();
    fetchMemberNames();
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("QR"),
        centerTitle: true,
      ),
      body: Center(
        child: showCheckmark
            ? _showCheckmarkScreen()
            : (!widget.isLeader ? _qrScanner() : _leaderPage()),
      ),
    );
  }

  // QR UI (Members)
  Widget _qrScanner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icon/img5.png', width: 120),
        SizedBox(height: 20),
        Text("SCAN QR Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.withOpacity(0.6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _pickFromGallery,
              icon: Icon(Icons.qr_code, color: Colors.white),
              label: Text("Pick from Gallery", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),

        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.remove('qr');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(), // make sure SignUpPage is imported
                      ),
                    );
                  },
                  child: const Text(
                    "Later",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),

        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "MeQat",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  //QR UI (Leaders)
  Widget _leaderPage() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/icon/img5.png', width: 120),
              SizedBox(height: 5),
              Text(
                "All members must scan this!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),
              QrImageView(
                data: qrId!,
                version: QrVersions.auto,
                size: 200.0,
              ),


              const SizedBox(height: 5),
              Text(
                "New members:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Container(
                width: 200,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isLoadingMembers
                    ? Center(child: CircularProgressIndicator()) // Loading spinner
                    : _noInternet
                    ? Center(
                  child: Text(
                    "No Internet Connection",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
                    : _memberNames.isEmpty
                    ? Center(
                  child: Text(
                    "No members found",
                    style: TextStyle(color: primaryColor),
                  ),
                )
                    : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 120),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _memberNames
                          .map((name) => Text(name, style: TextStyle(color: primaryColor)))
                          .toList(),
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.withOpacity(0.6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      handleQRCode(qrId!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    },
                    child: const Text("Done", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateAndSaveQRId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('qr');
    if (storedId == null) {
      final newId = const Uuid().v4();
      await prefs.setString('qr', newId);
      setState(() {
        qrId = newId;
      });
    } else {
      setState(() {
        qrId = storedId;
      });
    }
  }

  Future<void> handleQRCode(String qrCode) async {
    final prefs = await SharedPreferences.getInstance();
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;

    final isLeader = widget.isLeader;
    final uid = prefs.getString('uid');

    if (isConnected) {
      final firestore = FirebaseFirestore.instance;

      try {
        final docRef = firestore.collection('deligation').doc(qrCode);

        // Create or update deligation doc (just add timestamp)
        await docRef.set({'timestamp': FieldValue.serverTimestamp()}, SetOptions(merge: true));

        if (isLeader && uid != null) {
          // ✅ If user is leader, update users/{uid} with leader: true
          await firestore.collection('users').doc(uid).set(
            {
              'qr': qrCode,
              'leader': true, // 🔥 Added this line
            },
            SetOptions(merge: true),
          );

          // ✅ Also update deligation/{qr} with leader uid
          await docRef.update({
            'leader': uid,
          });

        } else {
          if (!isLeader && uid != null) {
            await firestore.collection('users').doc(uid).set(
              {
                'qr': qrCode,
                'leader': false, // 🔥 Added this line
              },
              SetOptions(merge: true),
            );
            // ✅ If user is not leader, just add to members array
            await docRef.update({
              'members': FieldValue.arrayUnion([uid]),
            });

            // ✅ (optional) you could also add {leader: false} to users if you want
          }
        }
      } catch (e) {
        print('Firestore error: $e');
      }
    }

    await prefs.setString('qr', qrCode);
  }

  Future<void> fetchMemberNames() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _noInternet = true;
          _isLoadingMembers = false;
        });
        return;
      }

      var delegationDoc = await FirebaseFirestore.instance.collection('delegation').doc('yourDelegationDocID').get();

      if (delegationDoc.exists) {
        List<dynamic> members = delegationDoc.data()?['members'] ?? [];

        List<String> names = [];

        for (var memberId in members) {
          var userDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
          if (userDoc.exists) {
            String firstName = userDoc.data()?['firstName'] ?? '';
            String lastName = userDoc.data()?['lastName'] ?? '';
            names.add('$firstName $lastName');
          }
        }

        setState(() {
          _memberNames = names;
          _isLoadingMembers = false;
        });
      } else {
        setState(() {
          _isLoadingMembers = false;
        });
      }

    } catch (e) {
      setState(() {
        _isLoadingMembers = false;
        _noInternet = true; // Assume error means no connection or Firestore problem
      });
    }
  }

  Widget _showCheckmarkScreen() {
    return Center(
      child: Icon(Icons.check_circle, size: 100, color: Colors.green),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      final qrCode = scanData.code;

      if (qrCode != null && qrCode.isNotEmpty) {
        qrId = qrCode;
        controller.pauseCamera();
        handleQRCode(qrId!);
        _showCheckmark();
      }
    });
  }

  void _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final qrCode = await _extractQRCode(File(pickedFile.path));
      if (qrCode != null) {
        handleQRCode(qrCode); // pass the actual decoded QR code
        _showCheckmark();
      } else {
        print("❌ No QR code found in the image.");
      }
    }
  }

  Future<String?> _extractQRCode(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final barcodeScanner = BarcodeScanner();

    // Use processImage to scan the QR code in the image
    final result = await barcodeScanner.processImage(inputImage);
    await barcodeScanner.close();

    // The result is a string value that represents the decoded QR code
    if (result.isNotEmpty) {
      return result[0].displayValue; // Display the first found value (QR code text)
    }

    return null; // No QR code found
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
          builder: (context) => HomePage(),
        ),
      );
    });
  }
}