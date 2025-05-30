import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Data.dart';

class SharedPref {
  Future<void> clearAll() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = await getLanguage();

    await prefs.clear();

    await saveLanguage(language);
  }
  Future<String?> getUID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }
  Future<void> saveUId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCodes = {'English': 'en', 'Arabic': 'ar'};
    await prefs.setString('language', languageCodes[language] ?? 'en');
  }
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'en';
  }

  Future<void> saveLeader(bool leader) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('leader', leader);
  }
  Future<bool?> getLeader() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('leader');
  }
  Future<void> saveLostUser(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lostUser', uid);
  }
  Future<String?> getLostUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lostUser');
  }
  Future<void> saveHelping(bool help) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('helping', help);
  }
  Future<bool?> getHelping() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('helping');
  }
  Future<void> saveFirstTime(bool firstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTime', firstTime);
  }
  getFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstTime');
  }
  Future<void> saveAuto(bool auto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto', auto);
  }
  getAuto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto');
  }
  Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firstName');
  }
  Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastName');
  }
  Future<void> saveUser(myUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', user.firstName.toString());
    await prefs.setString('lastName', user.lastName.toString());
    await prefs.setString('email', user.email.toString());
    await prefs.setString('password', user.password.toString());
    await prefs.setString('birthday', user.birthday.toString());
  }
  Future<myUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    myUser user = myUser();
    user.firstName = await prefs.getString('firstName');
    user.lastName = await prefs.getString('lastName');
    user.email = await prefs.getString('email');
    user.password = await prefs.getString('password');
    user.birthday = await prefs.getString('birthday');
    return user;
  }
  Future<void> updateUserName(String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');

    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      userMap['firstName'] = firstName;
      userMap['lastName'] = lastName;

      final updatedUserJson = jsonEncode(userMap);
      await prefs.setString('user', updatedUserJson);
    }
  }

  Future<File> saveImg(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedImage = await imageFile.copy('${directory.path}/$fileName');
    await prefs.setString('face_image', savedImage.path);
    return savedImage;
  }
  Future<String?> getImg() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('face_image');
  }

  Future<String?> getQRCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('qr');
  }
  Future<void> saveQRCode(String QR) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qr', QR);
  }
  Future<void> removeQRCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('qr');
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
  Future<Preference> getPreferences() async {
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

  Future<List<Alarm>> getAlarms() async {
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
   getIhramStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ihram') ?? false;
  }

  void saveDelegation (bool delegation) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('delegation', delegation);
  }
  Future<bool?> getDelegation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('delegation');
  }
}

