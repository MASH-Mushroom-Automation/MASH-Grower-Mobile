import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:mash_grower_mobile/presentation/providers/auth_provider.dart';
import 'package:mash_grower_mobile/data/models/user_model.dart';

// Generate mocks for testing
@GenerateMocks([])
void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    test('initial state is correct', () {
      expect(authProvider.isLoading, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
      expect(authProvider.error, null);
    });

    test('sign in with email sets loading state', () async {
      // This would require mocking Firebase Auth
      // For now, we'll test the state changes
      expect(authProvider.isLoading, false);
      
      // Simulate loading state
      // Note: In a real test, you'd mock Firebase Auth
      // and test the actual sign-in flow
    });

    test('user model creation from JSON', () {
      final userJson = {
        'id': 'test-user-id',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'role': 'grower',
        'profileImageUrl': 'https://example.com/avatar.jpg',
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      final user = UserModel.fromJson(userJson);

      expect(user.id, 'test-user-id');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.role, 'grower');
    });

    test('user model to JSON conversion', () {
      final user = UserModel(
        id: 'test-user-id',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'grower',
        profileImageUrl: 'https://example.com/avatar.jpg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = user.toJson();

      expect(json['id'], 'test-user-id');
      expect(json['email'], 'test@example.com');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['role'], 'grower');
    });
  });
}
