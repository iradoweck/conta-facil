import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/providers/auth_provider.dart';
import 'modules/auth/presentation/screens/splash_screen.dart';
import 'modules/auth/presentation/screens/login_screen.dart';
import 'core/presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: ContaFacilApp(),
    ),
  );
}

class ContaFacilApp extends ConsumerWidget {
  const ContaFacilApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final mockLoggedIn = ref.watch(mockLoggedInProvider);

    return MaterialApp(
      title: 'Conta Fácil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: mockLoggedIn 
          ? const MainScreen() 
          : authState.when(
              data: (user) => user != null ? const MainScreen() : const LoginScreen(),
              loading: () => const SplashScreen(),
              error: (e, s) => const LoginScreen(),
            ),
    );
  }
}
