import 'package:flutter/foundation.dart';

// Mock types to replace Firebase ones without importing the library
class MockUser {
  final String uid;
  final String? email;
  MockUser({required this.uid, this.email});
}

class MockUserCredential {
  final MockUser? user;
  MockUserCredential({this.user});
}

class AuthService {
  // Stream simulada
  Stream<dynamic> get authStateChanges => Stream.value(null);

  // Login simulado
  Future<dynamic> signIn(String email, String password) async {
    debugPrint("Mock login for: $email");
    // Simulamos um pequeno delay
    await Future.delayed(const Duration(milliseconds: 500));
    return MockUserCredential(user: MockUser(uid: 'mock_uid', email: email));
  }

  // Cadastro simulado
  Future<dynamic> signUp(String email, String password) async {
    debugPrint("Mock signup for: $email");
    await Future.delayed(const Duration(milliseconds: 500));
    return MockUserCredential(user: MockUser(uid: 'mock_uid', email: email));
  }

  // Logout simulado
  Future<void> signOut() async {
    debugPrint("Mock logout");
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
