import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Alarm {
  final String id;
  bool? enabled;
  String? medicineName;
  String? dosage;
  String? purpose;
  String? notes;
  String? doctor;
  String? whenToTake;
  String? importance;
  int timesPerDay;
  String repeatDays;
  List<bool> selectedDays;
  List<String> times = [];
  bool advanced;

  Alarm({
    required this.id,
    this.enabled,
    this.medicineName,
    this.dosage,
    this.purpose,
    this.notes,
    this.doctor,
    this.whenToTake,
    this.importance,
    this.timesPerDay = 1,
    this.times = const [],
    this.repeatDays = 'Once',
    List<bool>? selectedDays,
    this.advanced = false,
  }) : selectedDays = selectedDays ?? List.filled(7, false);

  Map<String, dynamic> toJson() => {
    'id': id,
    'enabled': enabled,
    'medicineName': medicineName,
    'dosage': dosage,
    'purpose': purpose,
    'notes': notes,
    'doctor': doctor,
    'whenToTake': whenToTake,
    'importance': importance,
    'timesPerDay': timesPerDay,
    'repeatDays': repeatDays,
    'selectedDays': selectedDays,
    'times' : times,
    'advanced': advanced,
  };

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      enabled: json['enabled'],
      medicineName: json['medicineName'],
      dosage: json['dosage'],
      purpose: json['purpose'],
      notes: json['notes'],
      doctor: json['doctor'],
      whenToTake: json['whenToTake'],
      importance: json['importance'],
      timesPerDay: json['timesPerDay'] ?? 1,
      times: List<String>.from(json['times'] ?? []),
      repeatDays: json['repeatDays'] ?? 'Once',
      selectedDays: List<bool>.from(json['selectedDays'] ?? List.filled(7, false)),
      advanced: json['advanced'] ?? false,
    );
  }
}
class Preference {
  bool? goal;
  bool? delegation;
  bool? leader;
  String? country;
  String? maddhab;
  String? transportation;
  String? language;
  int? saying;

  Preference({
    this.goal,
    this.delegation,
    this.leader,
    this.country,
    this.maddhab,
    this.transportation,
    this.language,
    this.saying,

  });

  Map<String, dynamic> toJson() => {
    'goal': goal,
    'delegation': delegation,
    'leader': leader,
    'country': country,
    'maddhab': maddhab,
    'transportation': transportation,
    'language': language,
    'saying': saying,
  };

  factory Preference.fromJson(Map<String, dynamic> json) {
    return Preference(
      goal: json['goal'],
      delegation: json['delegation'],
      leader: json['leader'],
      country: json['country'],
      maddhab: json['maddhab'],
      transportation: json['transportation'],
      language: json['language'],
      saying: json['saying'],
    );
  }
}

class myUser {
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? birthday;

  myUser({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.birthday,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
    'birthday': birthday,
  };


  factory myUser.fromJson(Map<String, dynamic> json) {
    return myUser(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      birthday: json['birthday'],
    );
  }
}

class Other {
  static final List<Map<String, String>> premiumItems = const [
    {
      "image": "assets/img/hotel.png",
      "title": "Fine Hotels That can be 60% to 75% cheaper",
    },
    {
      "image": "assets/img/food.png",
      "title":
      "Find more affordable meals 50% to 70% cheaper and more delicious",
    },
    {
      "image": "assets/img/shop.png",
      "title":
      "Shops 85% cheaper and items that can cost you 10-20 SAR instead",
    },
  ];
  List<Map<String, dynamic>> menuItems = [
    {'title': 'Delegation', 'icon': Icons.people},
    {'title': 'Ihram', 'icon': Icons.map},
    {'title': 'Hajj', 'icon': Icons.mosque},
    {'title': 'Umrah', 'icon': Icons.people},
    {'title': 'Lost', 'icon': Icons.location_off},
    {'title': 'Medicine', 'icon': Icons.alarm},
  ];
  static List<String> languages = ["English", "Arabic"];
  static List<String> goal = ["Hajj", "Umrah"];
  static List<String> madhhabs = ["Shafii", "Hanafi", "Hanbali", "Maliki"];
  static List<String> countries = ["Saudi Arabia", "Egypt", "Pakistan", "Malaysia", "Turkey"];
  static List<String> transportationMethods = ["By Air", "By Sea", "By Vehicle", "By foot"];
  static List<String> sayingDescriptions = [
    "❌ Not approved by maddhab Maliki\n❌ Not approved by maddhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii",  // Saying 1
    "❌ Not approved by maddhab Maliki\n❌ Not approved by maddhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii",  // Saying 2
    "✅ Approved by maddhab Maliki\n✅ Approved by maddhab Hanbali\n✅ Approved by maddhab Hanafi\n✅ Approved by maddhab Sahfii",  // Saying 3
    "Description for Saying 4",  // Saying 4
    "❌ Not approved by maddhab Maliki\n✅ Approved by madhhab Hanbali\n❌ Not approved by maddhab Hanafi\n❌ Not approved by maddhab Sahfii",  // Saying 5
  ];
  static final List<Map<String, dynamic>> miqatData = [
    {
      "name": "Dhul Hulaifa",
      "center": LatLng(24.413942807343183, 39.54297293708976),
      "closest": LatLng(24.390, 39.535),
      "farthest": LatLng(24.430, 39.550),
    },
    {
      "name": "Juhfa",
      "center": LatLng(22.71515249938801, 39.14514729649877),
      "closest": LatLng(22.700, 39.140),
      "farthest": LatLng(22.730, 39.160),
    },
    {
      "name": "Yalamlam",
      "center": LatLng(20.518564356141052, 39.870803989418974),
      "closest": LatLng(20.500, 39.850),
      "farthest": LatLng(20.540, 39.890),
    },
    {
      "name": "Dhat Irq",
      "center": LatLng(21.930072877611384, 40.42552892351149),
      "closest": LatLng(21.910, 40.400),
      "farthest": LatLng(21.950, 40.450),
    },
    {
      "name": "Qarn al-Manazil",
      "center": LatLng(21.63320606975049, 40.42677866397942),
      "closest": LatLng(21.610, 40.410),
      "farthest": LatLng(21.650, 40.440),
    },
  ];
  static final List<Map<String, String>> hajjSteps = [
    {
      'title': 'Step 1: Ihram',
      'description': 'Make intention and enter Ihram from Miqat with Talbiyah.'
    },
    {
      'title': 'Step 2: Tawaf al-Qudum',
      'description': 'Perform the arrival Tawaf (circumambulation of the Kaaba).'
    },
    {
      'title': 'Step 3: Sa’i between Safa and Marwah',
      'description': 'Walk 7 times between the hills of Safa and Marwah.'
    },
    {
      'title': 'Step 4: Stay at Mina',
      'description': 'On 8th Dhul Hijjah, stay in Mina and pray shortened prayers.'
    },
    {
      'title': 'Step 5: Day of Arafah',
      'description': 'On 9th Dhul Hijjah, stand in prayer and supplication at Arafah.'
    },
    {
      'title': 'Step 6: Muzdalifah',
      'description': 'Collect pebbles and spend the night under the sky in Muzdalifah.'
    },
    {
      'title': 'Step 7: Rami at Jamarat',
      'description': 'On 10th Dhul Hijjah, throw 7 pebbles at the Jamrah al-Aqabah.'
    },
    {
      'title': 'Step 8: Qurbani',
      'description': 'Offer animal sacrifice (or arrange it through a service).'
    },
    {
      'title': 'Step 9: Hair Cut/Shave',
      'description': 'Men shave or trim hair; women cut a small portion.'
    },
    {
      'title': 'Step 10: Tawaf al-Ifadah',
      'description': 'Mandatory Tawaf done after sacrifice and hair cutting.'
    },
    {
      'title': 'Step 11: Days of Tashreeq',
      'description': 'Stay in Mina and perform Rami for the next 2–3 days.'
    },
    {
      'title': 'Step 12: Tawaf al-Wida',
      'description': 'Farewell Tawaf before leaving Makkah (mandatory for non-locals).'
    },
  ];
  static final List<Map<String, String>> ihramSteps = [
    {
      'title': 'Step 1: Intention (Niyyah)',
      'description': 'Make your intention for Hajj or Umrah before entering the Miqat.'
    },
    {
      'title': 'Step 2: Ghusl and Cleanliness',
      'description': 'Perform full-body purification (ghusl), trim nails, and wear Ihram clothes.'
    },
    {
      'title': 'Step 3: Wearing Ihram',
      'description': 'Men wear 2 white sheets. Women wear modest Islamic dress.'
    },
    {
      'title': 'Step 4: Talbiyah',
      'description': 'Recite "Labbayk Allahumma Labbayk..." after entering Ihram.'
    },
    {
      'title': 'Step 5: Avoid Prohibited Acts',
      'description': 'Avoid cutting hair, perfume, arguing, or intimate relations while in Ihram.'
    },
  ];
  static final List<Map<String, String>> umrahSteps = [
    {
      'title': 'Step 1: Ihram',
      'description': 'Enter the state of Ihram from the Miqat with intention and Talbiyah.'
    },
    {
      'title': 'Step 2: Tawaf',
      'description': 'Perform 7 rounds of Tawaf around the Kaaba in a counter-clockwise direction.'
    },
    {
      'title': 'Step 3: Prayer at Maqam Ibrahim',
      'description': 'Pray two Rak’ahs behind Maqam Ibrahim after completing Tawaf.'
    },
    {
      'title': 'Step 4: Sa’i',
      'description': 'Walk 7 times between Safa and Marwah, starting at Safa and ending at Marwah.'
    },
    {
      'title': 'Step 5: Hair Cut or Shave',
      'description': 'Men shave or trim hair; women cut a small portion of their hair.'
    },
    {
      'title': 'Step 6: Exit Ihram',
      'description': 'After the haircut, you are out of Ihram and the Umrah is complete.'
    },
  ];
}