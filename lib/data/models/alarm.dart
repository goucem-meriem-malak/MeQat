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