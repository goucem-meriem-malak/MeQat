import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CreateSchoolDocPage(),
    );
  }
}

class CreateSchoolDocPage extends StatelessWidget {
  Future<void> createSchoolDoc() async {
    try {
      await FirebaseFirestore.instance
          .collection('school')
          .doc('01')
          .set({'name': 'hhhhh'});

      print("✅ Document added successfully!");
    } catch (e) {
      print("❌ Error adding document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create School Doc")),
      body: Center(
        child: ElevatedButton(
          onPressed: createSchoolDoc,
          child: Text("Create Document"),
        ),
      ),
    );
  }
}
