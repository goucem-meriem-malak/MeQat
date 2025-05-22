import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meqat/sharedPref.dart';
import 'Data.dart';

class UpdateFirebase{
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ Logged in as: ${credential.user?.email}");
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('❌ No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('❌ Wrong password provided.');
      } else {
        print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      }
    } catch (e) {
      print('❌ Login error: $e');
    }

    return null;
  }
  Future<void> UploadAlarmToFirebase(Alarm newAlarm) async {
    String? uid = await SharedPref().getUID();

    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('medicine').doc(uid);
    final alarmId = newAlarm.id;
    final alarmData = newAlarm.toJson();

    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        alarmId: [alarmData]
      });
      print('Created new doc with first alarm.');
    } else {
      final existingData = docSnapshot.data();

      if (existingData != null && existingData.containsKey(alarmId)) {
        await docRef.update({
          alarmId: FieldValue.arrayUnion([alarmData])
        });
      } else {
        await docRef.update({
          alarmId: [alarmData]
        });
        print('Created new alarm ID field.');
      }
    }
  }
  Future<void> deleteAlarmFromFirebase(String alarmId) async {
    String? uid = await SharedPref().getUID();

    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('medicine').doc(uid);

    try {
      await docRef.update({
        alarmId: FieldValue.delete(),
      });
      print('Deleted alarm with ID $alarmId from Firebase.');
    } catch (e) {
      print('Error deleting alarm: $e');
    }
  }
  Future<void> updateUserLocation(LatLng userLocation) async {
    String? uid = await SharedPref().getUID();

    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'location': GeoPoint(userLocation.latitude, userLocation.longitude),
        'lastUpdatedLocation': FieldValue.serverTimestamp(),
      });

      print("✅ Location updated for user $uid");
    } catch (e) {
      print("❌ Failed to update location: $e");
    }
  }
  Future<void> uploadPreferences(Map<String, dynamic> userData) async {
    String? uid = await SharedPref().getUID();

    if (uid != null) {
      final dataToUpload = Map<String, dynamic>.from(userData)
        ..putIfAbsent('uid', () => uid); // 👈 add uid inside the data

      await FirebaseFirestore.instance.collection('preferences').doc(uid).set(dataToUpload);
      print('✅ Uploaded to Firestore with UID: $uid');
    } else {
      print("❌ UID not found in SharedPreferences.");
    }
  }

}