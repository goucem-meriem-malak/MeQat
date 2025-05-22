import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Data.dart';

class SharedPref {
  Future<String?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  Future<void> savePreferences(Preference pref) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('goal', pref.goal ?? false);
    await prefs.setBool('delegation', pref.delegation ?? false);
    await prefs.setBool('leader', pref.leader ?? false);
    await prefs.setString('country', pref.country ?? '');
    await prefs.setString('maddhab', pref.maddhab ?? '');
    await prefs.setString('transportation', pref.transportation ?? '');
    await prefs.setString('language', pref.language ?? '');
    await prefs.setInt('saying', pref.saying ?? 0);
  }
  Future<Preference> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return Preference(
      goal: prefs.getBool('goal'),
      delegation: prefs.getBool('delegation'),
      leader: prefs.getBool('leader'),
      country: prefs.getString('country'),
      maddhab: prefs.getString('maddhab'),
      transportation: prefs.getString('transportation'),
      language: prefs.getString('language'),
      saying: prefs.getInt('saying'),
    );
  }
  Future<void> savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value == null) {
      await prefs.remove(key);
    } else {
      throw Exception('Unsupported value type for SharedPreferences');
    }
  }
  Future<T?> getPreference<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();

    if (T == bool) {
      return prefs.getBool(key) as T?;
    } else if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else {
      throw Exception('Unsupported type');
    }
  }


  Future<List<Alarm>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();

    final String? compressedBase64 = prefs.getString('alarms');
    if (compressedBase64 == null) return [];

    try {
      final List<int> compressedBytes = base64Decode(compressedBase64);
      final List<int> decompressedBytes = GZipDecoder().decodeBytes(compressedBytes);
      final String jsonString = utf8.decode(decompressedBytes);

      final List<dynamic> jsonData = jsonDecode(jsonString);
      return jsonData.map((item) => Alarm.fromJson(item)).toList();
    } catch (e) {
      print('Error loading alarms: $e');
      return [];
    }
  }
  Future<void> saveAlarms(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonData = alarms.map((alarm) => alarm.toJson()).toList();
    final String jsonString = jsonEncode(jsonData);

    final List<int> stringBytes = utf8.encode(jsonString);
    final List<int> compressedBytes = GZipEncoder().encode(stringBytes)!;
    final String compressedBase64 = base64Encode(compressedBytes);

    await prefs.setString('alarms', compressedBase64);
  }

  void saveIhramStatus(bool ihram) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('ihram', ihram);
  }
  Future<bool> getIhramStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ihram') ?? false;
  }


}

