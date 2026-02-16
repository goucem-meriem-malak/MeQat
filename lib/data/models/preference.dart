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