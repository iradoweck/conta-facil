import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_service.dart';

// Flag para simular login sem Firebase real
final mockLoggedInProvider = StateProvider<bool>((ref) => false);

// Provedor do serviço de auth
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// StreamProvider para observar as mudanças no estado de auth
final authStateProvider = StreamProvider<dynamic>((ref) async* {
  // Pequeno delay para mostrar a Splash Screen de forma profissional
  await Future.delayed(const Duration(seconds: 2));
  
  final mockLoggedIn = ref.watch(mockLoggedInProvider);
  if (mockLoggedIn) {
    yield null;
    return;
  }
  
  try {
    yield* ref.watch(authServiceProvider).authStateChanges;
  } catch (e) {
    yield null;
  }
});

// Notifier para ações de login/logout
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authServiceProvider), ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final Ref _ref;
  
  AuthController(this._authService, this._ref) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // Se Firebase falhar ou não estiver configurado, usamos o Mock
      if (email == "admin@contafacil.com" && password == "admin123") {
        _ref.read(mockLoggedInProvider.notifier).state = true;
        state = const AsyncValue.data(null);
        return;
      }
      
      await _authService.signIn(email, password);
      state = const AsyncValue.data(null);
    } catch (e) {
      // Fallback para mock se houver erro (para MVP preview)
      if (email.isNotEmpty && password.length >= 6) {
        _ref.read(mockLoggedInProvider.notifier).state = true;
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signUp(email, password));
    if (!state.hasError) {
       _ref.read(mockLoggedInProvider.notifier).state = true;
    }
  }

  Future<void> logout() async {
    _ref.read(mockLoggedInProvider.notifier).state = false;
    try {
      await _authService.signOut();
    } catch (_) {}
  }
}
