class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? countryCode;
  final String? dateOfBirth;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String? profileImage;
  final String? emergencyContactNumber;
  final String? emergencyContactName;
  final bool healthPreferenceOptIn;
  final bool acceptedTermsAndConditions;
  final bool acceptedPrivacyPolicy;
  final List<String> medicalHistory;
  final String? connectedDoctorId;
  final List<EmergencyContact> emergencyContacts;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.countryCode,
    this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    this.profileImage,
    this.emergencyContactNumber,
    this.emergencyContactName,
    this.healthPreferenceOptIn = false,
    this.acceptedTermsAndConditions = false,
    this.acceptedPrivacyPolicy = false,
    required this.medicalHistory,
    this.connectedDoctorId,
    required this.emergencyContacts,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      countryCode: json['countryCode'],
      dateOfBirth: json['dateOfBirth'],
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      height: json['height']?.toDouble() ?? 0.0,
      weight: json['weight']?.toDouble() ?? 0.0,
      profileImage: json['profileImage'],
      emergencyContactNumber: json['emergencyContactNumber'],
      emergencyContactName: json['emergencyContactName'],
      healthPreferenceOptIn: json['healthPreferenceOptIn'] ?? false,
      acceptedTermsAndConditions: json['acceptedTermsAndConditions'] ?? false,
      acceptedPrivacyPolicy: json['acceptedPrivacyPolicy'] ?? false,
      medicalHistory: List<String>.from(json['medicalHistory'] ?? []),
      connectedDoctorId: json['connectedDoctorId'],
      emergencyContacts: (json['emergencyContacts'] as List?)
          ?.map((e) => EmergencyContact.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'profileImage': profileImage,
      'emergencyContactNumber': emergencyContactNumber,
      'emergencyContactName': emergencyContactName,
      'healthPreferenceOptIn': healthPreferenceOptIn,
      'acceptedTermsAndConditions': acceptedTermsAndConditions,
      'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
      'medicalHistory': medicalHistory,
      'connectedDoctorId': connectedDoctorId,
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
    };
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String phone;
  final String email;
  final String? profileImage;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phone,
    required this.email,
    this.profileImage,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'phone': phone,
      'email': email,
      'profileImage': profileImage,
    };
  }
}