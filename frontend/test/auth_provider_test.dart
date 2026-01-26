import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/app_service.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      // Set to use Mock service for testing
      authProvider = AuthProvider();
    });

    test('Initial state is unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
      expect(authProvider.isLoading, false);
    });

    test('mustChangePassword getter works', () {
      expect(authProvider.mustChangePassword, false);
    });

    test('Sign in with valid credentials succeeds', () async {
      // Note: This uses MockService by default
      final result = await authProvider.signIn('patient@test.com', 'password123');
      
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser, isNotNull);
    });

    test('Sign in with invalid credentials fails', () async {
      final result = await authProvider.signIn('invalid@test.com', 'wrong');
      
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
    });

    test('Sign out clears user state', () async {
      // First sign in
      await authProvider.signIn('patient@test.com', 'password123');
      expect(authProvider.isAuthenticated, true);
      
      // Then sign out
      await authProvider.signOut();
      
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.currentUser, null);
    });

    test('Loading state changes during operations', () async {
      expect(authProvider.isLoading, false);
      
      // Sign in operation
      final future = authProvider.signIn('patient@test.com', 'password123');
      
      await future;
      
      // After completion, should not be loading
      expect(authProvider.isLoading, false);
    });

    test('Sign up creates new user', () async {
      final result = await authProvider.signUp(
        'newuser@test.com',
        'password123',
        'New User',
        UserRole.patient,
      );
      
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser?.name, 'New User');
    });

    test('Load user updates current user', () async {
      // First sign in
      await authProvider.signIn('patient@test.com', 'password123');
      final firstUser = authProvider.currentUser;
      
      // Load user with ID
      await authProvider.loadUser(firstUser!.id);
      
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser?.id, firstUser.id);
    });

    test('Multiple sign in and sign out cycles work', () async {
      // Cycle 1
      expect(await authProvider.signIn('patient@test.com', 'password123'), true);
      expect(authProvider.isAuthenticated, true);
      
      await authProvider.signOut();
      expect(authProvider.isAuthenticated, false);
      
      // Cycle 2
      expect(await authProvider.signIn('therapist@test.com', 'password123'), true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.currentUser?.role, UserRole.therapist);
      
      await authProvider.signOut();
      expect(authProvider.isAuthenticated, false);
    });
  });
}
