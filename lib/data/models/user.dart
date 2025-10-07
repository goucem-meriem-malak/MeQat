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