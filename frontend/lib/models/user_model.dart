enum UserRole {
  patient,
  therapist,
}

/// Available therapy modules
enum TherapyModule {
  writing,
  comprehension,
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
  final String? therapistId; // ID of the therapist who manages this patient
  final List<TherapyModule>? assignedModules; // Modules assigned by therapist
  final bool? onboardingEmailSent; // Track if onboarding email was sent
  final String? preferredLanguage; // Patient's preferred language ('en' or 'ms')
  final bool? mustChangePassword; // Require user to set a new password on first sign-in

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
    this.therapistId,
    this.assignedModules,
    this.onboardingEmailSent,
    this.preferredLanguage,
    this.mustChangePassword,
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
      'therapistId': therapistId,
      'assignedModules': assignedModules?.map((m) => m.name).toList(),
      'onboardingEmailSent': onboardingEmailSent,
      'preferredLanguage': preferredLanguage,
      'mustChangePassword': mustChangePassword,
    };
  }

  // Create from Map (from Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    print('DEBUG UserModel.fromMap: Full map keys: ${map.keys.toList()}');
    print('DEBUG UserModel.fromMap: assignedModules raw data: ${map["assignedModules"]} (type: ${map["assignedModules"].runtimeType})');
    
    // Handle assignedModules - convert from List<dynamic> of strings to List<TherapyModule>
    List<TherapyModule>? modules;
    try {
      final rawModules = map['assignedModules'];
      
      // Debug what we're working with
      print('DEBUG UserModel.fromMap: rawModules is null: ${rawModules == null}');
      print('DEBUG UserModel.fromMap: rawModules is List: ${rawModules is List}');
      
      if (rawModules != null && rawModules is List) {
        if (rawModules.isNotEmpty) {
          print('DEBUG UserModel.fromMap: Processing ${rawModules.length} modules');
          final convertedModules = <TherapyModule>[];
          
          for (final m in rawModules) {
            print('  - Mapping module: $m (type: ${m.runtimeType})');
            // Handle both String and already-converted enum values
            final moduleString = m is String ? m : (m is TherapyModule ? m.name : m.toString());
            
            // Find the matching enum value
            TherapyModule? foundModule;
            try {
              foundModule = TherapyModule.values.firstWhere(
                (e) => e.name == moduleString,
              );
              print('    ✅ Found module: $foundModule');
            } catch (e) {
              print('    ❌ Could not find module: $moduleString - defaulting to writing');
              foundModule = TherapyModule.writing;
            }
            
            convertedModules.add(foundModule);
          }
          
          modules = convertedModules;
          print('DEBUG UserModel.fromMap: Successfully converted to ${modules.length} modules: $modules');
        } else {
          print('DEBUG UserModel.fromMap: List is empty, modules will be null');
          modules = null;
        }
      } else if (rawModules != null) {
        print('DEBUG UserModel.fromMap: assignedModules is not a List, it is: ${rawModules.runtimeType}');
        modules = null;
      } else {
        print('DEBUG UserModel.fromMap: assignedModules is null');
        modules = null;
      }
    } catch (e) {
      print('ERROR UserModel.fromMap: Exception processing assignedModules: $e');
      modules = null;
    }
    
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
      therapistId: map['therapistId'],
      assignedModules: modules,
      onboardingEmailSent: map['onboardingEmailSent'],
      preferredLanguage: map['preferredLanguage'],
      mustChangePassword: map['mustChangePassword'],
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    String? diagnosis,
    String? patientPhone,
    String? caregiverName,
    String? caregiverPhone,
    String? therapistId,
    List<TherapyModule>? assignedModules,
    bool? onboardingEmailSent,
    String? preferredLanguage,
    bool? mustChangePassword,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      diagnosis: diagnosis ?? this.diagnosis,
      patientPhone: patientPhone ?? this.patientPhone,
      caregiverName: caregiverName ?? this.caregiverName,
      caregiverPhone: caregiverPhone ?? this.caregiverPhone,
      therapistId: therapistId ?? this.therapistId,
      assignedModules: assignedModules ?? this.assignedModules,
      onboardingEmailSent: onboardingEmailSent ?? this.onboardingEmailSent,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}

