import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meqat/Profile.dart';
import 'package:meqat/menu.dart';
import 'package:meqat/premium.dart';
import 'package:meqat/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Data.dart';
import '../home.dart';

void main() {
  runApp(MedicineAlarmApp());
}

class MedicineAlarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MedicinePage(),
    );
  }
}

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  List<Map<String, dynamic>> alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedAlarms = prefs.getString('alarms');
    if (savedAlarms != null) {
      setState(() {
        alarms = List<Map<String, dynamic>>.from(jsonDecode(savedAlarms));
      });
    }
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('alarms', jsonEncode(alarms));
  }

  void _showAddAlarmDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddAlarmPage(onSave: (alarm) {
        setState(() {
          alarms.add(alarm);
          _saveAlarms();
        });
      }),
    );
  }

  void _showDeleteAlarmDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Alarm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: alarms.map((alarm) {
              return ListTile(
                title: Text(alarm['time']),
                subtitle: Text(alarm['medicine']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      alarms.remove(alarm);
                      _saveAlarms();
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _pickTime(int index) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateFormat.jm().parse(alarms[index]['time'])),
    );
    if (picked != null) {
      setState(() {
        alarms[index]['time'] = picked.format(context);
        _saveAlarms();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.deepPurple,),
            onPressed: _showDeleteAlarmDialog,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: alarms.map((alarm) {
          int index = alarms.indexOf(alarm);
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: GestureDetector(
                onTap: () => _pickTime(index),
                child: Text(
                  alarm['time'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              subtitle: Text("Alarm set"),
              trailing: Switch(
                value: alarm['enabled'],
                onChanged: (value) {
                  setState(() {
                    alarm['enabled'] = value;
                    _saveAlarms();
                  });
                },
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAlarmDialog,
        child: Icon(Icons.add),
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
              Expanded(
                child : UI().buildNavItem(Icons.menu, "Menu", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPage()));
                }, true),
              ),

              Expanded(
                child :  UI().buildNavItem(Icons.search, "Search", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SearchPage()));
                }, false),
              ),

              Expanded(
                child : UI().buildNavItem(Icons.home, "Home", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
                }, false),),

              Expanded(
                child : UI().buildNavItem(Icons.star, "Premium", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumPage()));
                }, false),),

              Expanded(
                child : UI().buildNavItem(Icons.settings, "Profile", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => profilePage()));
                }, false),), // Profile is selected
            ],
          ),
        ),
      ),
    );
  }
}

class AddAlarmPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  AddAlarmPage({required this.onSave});

  @override
  _AddAlarmPageState createState() => _AddAlarmPageState();
}

class _AddAlarmPageState extends State<AddAlarmPage> {
  String medicineName = "";
  TimeOfDay selectedTime = TimeOfDay.now();
  String repeat = 'Once';
  List<bool> selectedDays = List.filled(7, false);

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Medicine Name'),
                  onChanged: (value) => medicineName = value,
                ),
              ),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  if (medicineName.isNotEmpty) {
                    widget.onSave({
                      'time': selectedTime.format(context),
                      'medicine': medicineName,
                      'repeat': repeat,
                      'days': selectedDays,
                      'enabled': true
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: _pickTime,
            child: Text(
              selectedTime.format(context),
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),
          Text('Advanced >', style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }
}