import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/shared_pref.dart';
import '../models/alarm.dart';
import '../models/user.dart';


class UpdateFirebase{
  Future<String> createDoc(String col) async{
    final docRef = FirebaseFirestore.instance.collection(col).doc();
    return docRef.id;
  }
  /*Future<UserCredential?> loginWithEmail(String email, String password) async {
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

   */
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

  Future<List<Map<String, String>>> fetchDelegationMembers(String qrCode) async {
    final doc = await FirebaseFirestore.instance
        .collection('delegation')
        .doc(qrCode)
        .get();

    final members = doc.data()?['members'] ?? [];
    final memberList = <Map<String, String>>[];

    for (final memberId in members) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .get();

      final firstName = userDoc.data()?['firstName'] ?? '';
      final lastName = userDoc.data()?['lastName'] ?? '';
      final fullName = '$firstName $lastName'.trim();

      memberList.add({
        'id': memberId,
        'name': fullName,
      });
    }

    return memberList;
  }
  Future<List<Map<String, String>>> loadMembers(String qr) async {
    final delegationDoc = await FirebaseFirestore.instance.collection('delegation').doc(qr).get();
    final data = delegationDoc.data();
    final String? leaderId = data?['leader'];
    final List<dynamic>? members = data?['members'];
    List<Map<String, String>> loadedMembers = [];

    if (leaderId != null) {
      final leaderDoc = await FirebaseFirestore.instance.collection('users').doc(leaderId).get();
      if (leaderDoc.exists) {
        final leaderData = leaderDoc.data();
        final firstName = leaderData?['firstName'] ?? '';
        final lastName = leaderData?['lastName'] ?? '';
        final location = leaderData?['location'] ?? '';
        loadedMembers.add({
          'firstName': firstName,
          'lastName': lastName,
          'location': location,
        });
      }
    }

    if (members != null && members.isNotEmpty) {
      for (var memberId in members) {
        if (memberId != leaderId) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            final firstName = userData?['firstName'] ?? '';
            final lastName = userData?['lastName'] ?? '';
            final location = userData?['location'] ?? '';
            loadedMembers.add({
              'firstName': firstName,
              'lastName': lastName,
              'location': location,
            });
          }
        }
      }
    }

    return loadedMembers;
  }

  Future<GeoPoint?> loadUserLocation(String userId, {required bool isLeader}) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    GeoPoint? location;
    if (userDoc.exists) {
      var data = userDoc.data();
      location = data?['location'];
      return location;
    }
    return location;
  }
  Future<void> addDelegation(bool leader, String qr) async {
    final uid = await SharedPref().getUID();
    final delegationRef = FirebaseFirestore.instance.collection('delegation').doc(qr);

    if (leader) {
      await delegationRef.set({
        'leader': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'members': {},
      });
    } else {
      await delegationRef.update({
        'members': FieldValue.arrayUnion([uid]),
      });
    }
  }
  Future<List<Map<String, dynamic>>> getDelegationMembersInfo(String uid, String qr) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<Map<String, dynamic>> membersInfo = [];

    try {
      DocumentSnapshot delegationDoc = await firestore.collection('delegation').doc(qr).get();

      if (!delegationDoc.exists) {
        throw Exception('Delegation not found for QR: $qr');
      }

      final data = delegationDoc.data() as Map<String, dynamic>;

      if (data['leader'] != uid) {
        throw Exception('User is not the leader of this delegation.');
      }

      // 3. Get the members list
      List<dynamic> memberIds = data['members'] ?? [];

      for (String memberId in memberIds) {
        // 4. Fetch each member's data from "users" collection
        DocumentSnapshot userDoc = await firestore.collection('users').doc(memberId).get();

        if (!userDoc.exists) continue;

        final userData = userDoc.data() as Map<String, dynamic>;

        GeoPoint? location = userData['location'];
        String? firstName = userData['firstName'];
        String? lastName = userData['lastName'];

        if (location != null && firstName != null && lastName != null) {
          membersInfo.add({
            'uid': memberId,
            'firstName': firstName,
            'lastName': lastName,
            'location': location,
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching delegation members: $e');
    }

    return membersInfo;
  }
  Future<List<Map<String, dynamic>>> getGroupMembersAndLeader(String uid, String qr) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> result = [];

    try {
      // 1. Get the delegation document using QR
      DocumentSnapshot delegationDoc = await firestore.collection('delegation').doc(qr).get();

      if (!delegationDoc.exists) {
        throw Exception('Delegation not found for QR: $qr');
      }

      final data = delegationDoc.data() as Map<String, dynamic>;

      // 2. Check if current user is part of the members list
      List<dynamic> members = data['members'] ?? [];
      if (!members.contains(uid)) {
        throw Exception('User is not part of this delegation.');
      }

      // 3. Get the leader UID (assume it's the first member or explicitly provided)
      String leaderUid = data['leader'] ?? (members.isNotEmpty ? members.first : null);
      Set<String> userIds = {leaderUid};

      // 4. Add all members except current user
      for (String memberId in members) {
        if (memberId != uid) {
          userIds.add(memberId);
        }
      }

      // 5. Fetch each user's name and location
      for (String userId in userIds) {
        DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

        if (!userDoc.exists) continue;

        final userData = userDoc.data() as Map<String, dynamic>;

        GeoPoint? location = userData['location'];
        String? firstName = userData['firstName'];
        String? lastName = userData['lastName'];

        if (location != null && firstName != null && lastName != null) {
          result.add({
            'uid': userId,
            'firstName': firstName,
            'lastName': lastName,
            'location': location,
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching members and leader: $e');
    }

    return result;
  }

  Future<void> addUser(myUser user, String uid) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await docRef.set(user.toJson(), SetOptions(merge: true));
  }
  Future<myUser?> getUser() async {
    final uid = await SharedPref().getUID();
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        return myUser.fromJson({'uid': uid, ...data});
      }
    }
    return null;
  }
  Future<myUser?> getLostUser(String uid) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        return myUser.fromJson({'uid': uid, ...data});
      }
    }
    return null;
  }
  Future<Map<String, String>?> getUserNameByUID(String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final docSnapshot = await firestore.collection('users').doc(uid).get();

      if (!docSnapshot.exists) {
        print('User not found for UID: $uid');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }

      final String firstName = data['firstName'] ?? '';
      final String lastName = data['lastName'] ?? '';

      return {
        'firstName': firstName,
        'lastName': lastName,
      };
    } catch (e) {
      print('Error fetching user name: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllMemberInfoByLeaderUID(String leaderUID) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // 1️⃣ Find delegation where leader == leaderUID
      final querySnapshot = await firestore
          .collection('delegation')
          .where('leader', isEqualTo: leaderUID)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No delegation found for leader UID: $leaderUID');
        return null;
      }

      // Get the first matching delegation doc (assuming only one)
      final delegationDoc = querySnapshot.docs.first;
      final membersList = delegationDoc.get('members') as List<dynamic>?;

      if (membersList == null || membersList.isEmpty) {
        print('No members found for leader UID: $leaderUID');
        return null;
      }

      // 2️⃣ Fetch each member's info from 'users' collection
      List<Map<String, dynamic>> memberInfoList = [];

      for (var memberUID in membersList) {
        final userDoc = await firestore.collection('users').doc(memberUID).get();

        if (userDoc.exists) {
          final firstName = userDoc.get('firstName') ?? '';
          final lastName = userDoc.get('lastName') ?? '';
          final location = userDoc.get('location'); // could be GeoPoint or Map

          memberInfoList.add({
            'uid': memberUID,
            'firstName': firstName,
            'lastName': lastName,
            'location': location,
          });
        } else {
          print('User not found for UID: $memberUID');
        }
      }

      return memberInfoList;
    } catch (e) {
      print('Error fetching members info: $e');
      return null;
    }
  }

/*
  Future<Map<String, dynamic>?> getLeaderLocationAndName(String foundUserUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Step 1: Find the leader UID in 'delegation' collection
      final delegationQuery = await firestore.collection('delegation').get();

      String? leaderUid;

      for (var doc in delegationQuery.docs) {
        final membersMap = doc.get('members') as Map<String, dynamic>;

        if (membersMap.containsKey(foundUserUid)) {
          leaderUid = doc.get('leader');
          break;
        }
      }

      if (leaderUid == null) {
        print('No matching delegation found for user $foundUserUid.');
        return null;
      }

      // Step 2: Get leader's location and name from 'users' collection
      final leaderDoc = await firestore.collection('users').doc(leaderUid).get();

      if (!leaderDoc.exists) {
        print('Leader user not found for UID $leaderUid.');
        return null;
      }

      final location = leaderDoc.get('location'); // e.g., GeoPoint or LatLng
      final firstName = leaderDoc.get('firstName') ?? '';
      final lastName = leaderDoc.get('lastName') ?? '';

      return {
        'location': location,
        'firstName': firstName,
        'lastName': lastName,
      };
    } catch (e) {
      print('Error getting leader location and name: $e');
      return null;
    }
  }


 */
  Future<Map<String, dynamic>?> getLeaderLocationAndName(String foundUserUid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final delegationQuery = await firestore.collection('delegation').get();

      String? leaderUid;

      // Loop through delegation docs to find the user in members
      for (var doc in delegationQuery.docs) {
        final data = doc.data();

        final membersRaw = data['members'];

        List<String> membersList = [];

        if (membersRaw is List) {
          // If it's a List<dynamic>, cast to List<String>
          membersList = membersRaw.cast<String>();
        } else if (membersRaw is Map) {
          // Defensive: if it's a Map, get keys as strings
          membersList = membersRaw.keys.cast<String>().toList();
        } else {
          // members field is null or unexpected type - keep empty list
          membersList = [];
        }

        if (membersList.contains(foundUserUid)) {
          leaderUid = data['leader'] as String?;
          break;
        }
      }

      if (leaderUid == null) {
        print('User $foundUserUid is not found in any delegation members.');
        return null;
      }

      // Get leader info from users collection
      final leaderDoc = await firestore.collection('users').doc(leaderUid).get();

      if (!leaderDoc.exists) {
        print('Leader with UID $leaderUid does not exist.');
        return null;
      }

      final leaderData = leaderDoc.data();
      if (leaderData == null) {
        print('No data found for leader user.');
        return null;
      }

      return {
        'firstName': leaderData['firstName'] ?? '',
        'lastName': leaderData['lastName'] ?? '',
        'location': leaderData['location'],
      };
    } catch (e) {
      print('Error in getLeaderLocationAndName: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLeaderInfo(String qr) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      // Step 1: Get the leader UID from delegation collection
      final delegationDoc = await _firestore.collection('delegation').doc(qr).get();

      if (!delegationDoc.exists) {
        print("🚫 Delegation document not found for QR: $qr");
        return null;
      }

      final leaderUid = delegationDoc.data()?['leader'];
      if (leaderUid == null) {
        print("🚫 Leader field is missing in delegation document: $qr");
        return null;
      }

      // Step 2: Get leader details from users collection
      final userDoc = await _firestore.collection('users').doc(leaderUid).get();

      if (!userDoc.exists) {
        print("🚫 User document not found for leader UID: $leaderUid");
        return null;
      }

      final firstName = userDoc.data()?['firstName'] ?? '';
      final lastName = userDoc.data()?['lastName'] ?? '';
      final location = userDoc.data()?['location'] ?? '';

      return {
        'location': location,
        'firstName': firstName,
        'lastName': lastName,
        'uid': leaderUid,
      };

    } catch (e) {
      print("❌ Error getting leader info: $e");
      return null;
    }
  }

  /*
  Future<String?> uploadPic(File imageFile)async {
    final uid = SharedPref().getUID();
   final storageRef = FirebaseStorage.instance.ref().child('user/$uid.jpg');

    final uploadTask = await storageRef.putFile(imageFile);

    // Get download URL
    return await uploadTask.ref.getDownloadURL();
    }*/
  Future<String?> uploadPicSupbase(File imageFile) async {
    try {
      final supabase = Supabase.instance.client;
      final uid = await SharedPref().getUID();

      final storagePath = '$uid.jpg';

      // Upload file
      final response = await supabase.storage
          .from('users')
          .upload(
        storagePath,
        imageFile,
        fileOptions: FileOptions(
          contentType: 'image/jpeg',
        ),
      );

      if (response.isNotEmpty) {
        print('✅ Image uploaded to Supabase: $storagePath');

        final publicUrl = supabase.storage
            .from('users')
            .getPublicUrl(storagePath);
        return publicUrl;
      } else {
        print('❌ Upload error: $response');
        return null;
      }
    } catch (e) {
      print('❌ Upload failed: $e');
      return null;
    }
  }
  Future<bool> isLeaderInPreferences(String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final docSnapshot = await firestore.collection('preferences').doc(uid).get();

      if (!docSnapshot.exists) {
        return false; // Or default value if preferred
      }

      final data = docSnapshot.data();
      if (data == null) {
        return false; // Or default value if preferred
      }

      // Return the actual boolean value of 'leader' field
      return data['leader'] == true; // Ensure it's a bool and true
    } catch (e) {
      print('Error checking leader in preferences: $e');
      return false; // Or throw if you want to handle errors differently
    }
  }
  Future<bool> isDelegationInPreferences(String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final docSnapshot = await firestore.collection('preferences').doc(uid).get();

      if (!docSnapshot.exists) {
        return false;
      }

      final data = docSnapshot.data();
      if (data == null) {
        return false;
      }

      return data.containsKey('delegation') && data['delegation'] != null;
    } catch (e) {
      print('Error checking leader in preferences: $e');
      return false;
    }
  }
}