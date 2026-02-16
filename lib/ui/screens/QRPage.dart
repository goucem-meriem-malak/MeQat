import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/local/shared_pref.dart';
import '../../data/services/firebase_service.dart';
import '../../l10n/app_localizations.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:uuid/uuid.dart';


import 'home.dart';

class QRPage extends StatefulWidget {
  final bool isLeader;
  const QRPage({required this.isLeader});

  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final qrKey = GlobalKey(debugLabel: 'qr');
  final primaryColor = const Color(0xFF2D2D2D);
  String? qrId;
  bool showCheckmark = false;

  final MobileScannerController scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _generateAndSaveQRId();
  }

  @override
  void dispose() {
    // Dispose the new controller
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
        child: widget.isLeader ? _leaderPage() : _memberPage(),
      ),
    );
  }

  Widget _memberPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Text(AppLocalizations.of(context)!.scan_qr_code, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Spacer(flex: 1),
        Center(
          child: Text(
            AppLocalizations.of(context)!.member_qr_scan_text,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 16),
        // UPDATED CONTAINER START
        Container(
          height: 400,
          width: 400,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: MobileScanner(
              controller: scannerController,
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null && code.isNotEmpty) {
                    // Stop camera so it doesn't trigger multiple times
                    await scannerController.stop();
                    await handleQRCode(code);
                    _showCheckmark();
                  }
                }
              },
            ),
          ),
        ),
        // UPDATED CONTAINER END
        const Spacer(flex: 2),
        _customButton(
          icon: Icons.qr_code,
          label: AppLocalizations.of(context)!.pick_gallery,
          onPressed: _pickFromGallery,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            await SharedPref().removeQRCode();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
          },
          child: Text(AppLocalizations.of(context)!.later, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
        ),
        const Spacer(flex: 1),
        const Text("MeQat", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _leaderPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Text(AppLocalizations.of(context)!.members_must_scan, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Spacer(flex: 1),
        Center(
          child: Text(
            AppLocalizations.of(context)!.leader_qr_scan_text,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 16),
        QrImageView(data: qrId!, version: QrVersions.auto, size: 200),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.new_members, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        _memberListDisplay(qrId!),
        const Spacer(flex: 1),
        _customButton(
          label: AppLocalizations.of(context)!.done,
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
          },
        ),
        const Spacer(flex: 1),
        const Text("MeQat", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _customButton({required String label, IconData? icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox.shrink(),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _generateAndSaveQRId() async {
    String? storedId = await SharedPref().getQRCode();
    if (storedId == null || storedId.isEmpty) {
      final newId = const Uuid().v4();
      qrId = newId;
    } else {
      qrId = storedId;
    }
    handleQRCode(qrId!);
    setState(() {});
  }

  Future<void> handleQRCode(String qrCode) async {
    await SharedPref().saveQRCode(qrCode);
    await UpdateFirebase().addDelegation(widget.isLeader, qrCode);
  }

  Widget _memberListDisplay(String qrcode) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('delegation').doc(qrcode).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text(AppLocalizations.of(context)!.no_members, style: TextStyle(color: primaryColor));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null || data['members'] == null) {
            return Text(AppLocalizations.of(context)!.no_members, style: TextStyle(color: primaryColor));
          }

          final members = (data['members'] as Map<String, dynamic>?) ?? {};

          if (members.isEmpty) {
            return Text(AppLocalizations.of(context)!.no_members, style: TextStyle(color: primaryColor), textAlign: TextAlign.center,);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.new_members,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: ListView(
                  shrinkWrap: true,
                  children: members.keys
                      .map((uid) => Text(uid, style: const TextStyle(fontSize: 14)))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCheckmark() {
    if (!mounted) return;
    setState(() => showCheckmark = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => showCheckmark = false);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
      }
    });
  }
  void _pickFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _showCheckmark();
    }
  }

}
