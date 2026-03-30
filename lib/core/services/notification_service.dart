import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service to handle Firebase Cloud Messaging (Push Notifications)
/// 
/// [IMPORTANT] PARA PRODUÇÃO:
/// 1. Vá ao Firebase Console > Project Settings > Cloud Messaging.
/// 2. Gere um "Web Push certificates" (VAPID Key).
/// 3. Substitua a chave 'YOUR_VAPID_KEY_HERE' abaixo pela sua chave real.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Chave DEMO (MOCK) - Substituir em produção
  static const String _vapidKey = "BD_DEMO_KEY_CONTA_FACIL_MOCK_VAPID_REPLACE_ME_IN_PRODUCTION";

  static Future<void> initialize() async {
    if (kIsWeb) {
      // Configurações específicas para Web
      log("🔔 NotificationService: Inicializando Web Push...");
    }
  }

  static Future<bool> requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('✅ Usuário aceitou as notificações');
      
      // Obter Token para o Backend
      try {
        String? token = await _messaging.getToken(
          vapidKey: kIsWeb ? _vapidKey : null,
        );
        log('🎫 FCM TOKEN: $token');
        return true;
      } catch (e) {
        log('❌ Erro ao obter Token: $e');
        return false;
      }
    } else {
      log('🚫 Usuário recusou as notificações');
      return false;
    }
  }

  static void listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('📩 Mensagem recebida em primeiro plano: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('🖱️ Usuário clicou na notificação!');
    });
  }
}
