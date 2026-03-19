import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/financeiro/presentation/screens/dashboard_screen.dart';

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
          ? const DashboardScreen() 
          : authState.when(
              data: (user) => user != null ? const DashboardScreen() : const LoginScreen(),
              loading: () => const SplashScreen(),
              error: (e, s) => const LoginScreen(),
            ),
    );
  }
}
