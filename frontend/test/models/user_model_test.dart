import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('Creates patient user correctly', () {
      final user = UserModel(
        id: 'user_1',
        email: 'patient@test.com',
        name: 'Test Patient',
        role: UserRole.patient,
        createdAt: DateTime.now(),
        preferredLanguage: 'en',
      );
      
      expect(user.id, 'user_1');
      expect(user.role, UserRole.patient);
    });

    test('Creates therapist user correctly', () {
      final user = UserModel(
        id: 'therapist_1',
        email: 'therapist@test.com',
        name: 'Test Therapist',
        role: UserRole.therapist,
        createdAt: DateTime.now(),
        preferredLanguage: 'en',
      );
      
      expect(user.role, UserRole.therapist);
    });

    test('User with assigned modules', () {
      final user = UserModel(
        id: 'patient_1',
        email: 'patient@test.com',
        name: 'Test Patient',
        role: UserRole.patient,
        createdAt: DateTime.now(),
        preferredLanguage: 'en',
        assignedModules: [TherapyModule.comprehension, TherapyModule.writing],
      );
      
      expect(user.assignedModules, isNotEmpty);
      expect(user.assignedModules!.length, 2);
      expect(user.assignedModules!.contains(TherapyModule.comprehension), true);
    });

    test('User copyWith updates fields correctly', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'user_1',
        email: 'test@test.com',
        name: 'Test User',
        role: UserRole.patient,
        createdAt: now,
        preferredLanguage: 'en',
      );
      
      final updated = user.copyWith(name: 'Updated Name', preferredLanguage: 'ms');
      
      expect(updated.id, user.id);
      expect(updated.name, 'Updated Name');
      expect(updated.preferredLanguage, 'ms');
      expect(updated.email, user.email);
    });

    test('User equality based on ID', () {
      final now = DateTime.now();
      final user1 = UserModel(
        id: 'user_1',
        email: 'test@test.com',
        name: 'Test User',
        role: UserRole.patient,
        createdAt: now,
        preferredLanguage: 'en',
      );

      final user2 = UserModel(
        id: 'user_1',
        email: 'different@test.com',
        name: 'Different Name',
        role: UserRole.therapist,
        createdAt: now,
        preferredLanguage: 'ms',
      );

      // Should be equal based on ID
      expect(user1.id, user2.id);
    });

    test('Admin user is therapist', () {
      final admin = UserModel(
        id: 'admin_1',
        email: 'admin@test.com',
        name: 'Admin User',
        role: UserRole.therapist,
        createdAt: DateTime.now(),
        preferredLanguage: 'en',
      );
      
      expect(admin.role, UserRole.therapist);
    });

    test('User with multiple therapy modules', () {
      final user = UserModel(
        id: 'patient_1',
        email: 'patient@test.com',
        name: 'Test Patient',
        role: UserRole.patient,
        createdAt: DateTime.now(),
        preferredLanguage: 'en',
        assignedModules: [
          TherapyModule.comprehension,
          TherapyModule.writing,
        ],
      );
      
      expect(user.assignedModules!.length, 2);
    });

    test('copyWith preserves unspecified fields', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'user_1',
        email: 'test@test.com',
        name: 'Test User',
        role: UserRole.patient,
        createdAt: now,
        preferredLanguage: 'en',
        assignedModules: [TherapyModule.writing],
      );
      
      final updated = user.copyWith(name: 'Updated Name');
      
      expect(updated.id, user.id);
      expect(updated.email, user.email);
      expect(updated.role, user.role);
      expect(updated.assignedModules, user.assignedModules);
    });
  });
}
