enum UserRole {
  patient,
  therapist,
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  // Patient-specific fields
  final String? diagnosis; // Type of aphasia
  final String? patientPhone; // Patient phone number
  final String? caregiverName;
  final String? caregiverPhone;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.diagnosis,
    this.patientPhone,
    this.caregiverName,
    this.caregiverPhone,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'diagnosis': diagnosis,
      'patientPhone': patientPhone,
      'caregiverName': caregiverName,
      'caregiverPhone': caregiverPhone,
    };
  }

  // Create from Map (from Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.patient,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      diagnosis: map['diagnosis'],
      patientPhone: map['patientPhone'],
      caregiverName: map['caregiverName'],
      caregiverPhone: map['caregiverPhone'],
    );
  }
}

