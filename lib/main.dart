import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/providers/auth_provider.dart';
import 'modules/transactions/providers/transaction_provider.dart';
import 'modules/auth/presentation/screens/splash_screen.dart';
import 'modules/auth/presentation/screens/login_screen.dart';
import 'core/presentation/screens/main_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:conta_facil/firebase_options.dart';
import 'package:conta_facil/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialização Mock do Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.initialize();
    NotificationService.listenToMessages();
  } catch (e) {
    debugPrint('⚠️ Firebase Init Skip/Error: $e');
  }

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
    final themeMode = ref.watch(userSettingsProvider.select((s) => s.themeMode));

    return MaterialApp(
      title: 'Conta Fácil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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
