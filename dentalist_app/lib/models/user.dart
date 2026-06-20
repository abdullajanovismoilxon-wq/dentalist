class User {
  final int id;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatar;
  final String role;
  final bool isDoctor;
  final String? bloodGroup;
  final String? allergies;
  final String? gender;
  final String? dateOfBirth;

  User({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.avatar,
    this.role = 'user',
    this.isDoctor = false,
    this.bloodGroup,
    this.allergies,
    this.gender,
    this.dateOfBirth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      phone: json['phone'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      avatar: json['avatar'],
      role: json['role'] ?? 'user',
      isDoctor: json['role'] == 'doctor',
      bloodGroup: json['blood_group'],
      allergies: json['allergies'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'avatar': avatar,
      'role': role,
      'blood_group': bloodGroup,
      'allergies': allergies,
      'gender': gender,
      'date_of_birth': dateOfBirth,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? phone;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}';
    }
    if (firstName != null) return firstName![0];
    if (lastName != null) return lastName![0];
    return phone.isNotEmpty ? phone[0] : 'U';
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? avatar,
    String? bloodGroup,
    String? allergies,
    String? gender,
    String? dateOfBirth,
  }) {
    return User(
      id: id,
      phone: phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role,
      isDoctor: isDoctor,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }
}
