import 'dart:async';
import 'package:flutter/foundation.dart';

/// Uma versão simulada do AuthService para permitir testes de UI sem Firebase real.
class MockAuthService {
  final _controller = StreamController<dynamic>();
  dynamic _currentUser;

  Stream<dynamic> get authStateChanges => _controller.stream;

  MockAuthService() {
    // Inicialmente deslogado
    _controller.add(null);
  }

  Future<dynamic> signIn(String email, String password) async {
    // Simula atraso de rede
    await Future.delayed(const Duration(seconds: 1));
    
    // Qualquer e-mail/senha funciona no mock
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = null; 
      _controller.add(null); 
      return null;
    }
    throw Exception('Usuário não encontrado.');
  }

  Future<dynamic> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return null;
  }

  Future<void> signOut() async {
    _controller.add(null);
  }
}
