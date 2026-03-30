// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// [IMPORTANT] PARA PRODUÇÃO:
/// Este ficheiro foi gerado com chaves DEMO/MOCK.
/// Para usar o Firebase real, instale a FlutterFire CLI e execute:
/// `flutterfire configure`
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'DEMO_API_KEY_CONTA_FACIL',
    appId: '1:123456789:web:abcdef',
    messagingSenderId: '123456789',
    projectId: 'conta-facil-demo',
    authDomain: 'conta-facil-demo.firebaseapp.com',
    storageBucket: 'conta-facil-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'DEMO_API_KEY_CONTA_FACIL',
    appId: '1:123456789:android:abcdef',
    messagingSenderId: '123456789',
    projectId: 'conta-facil-demo',
    storageBucket: 'conta-facil-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'DEMO_API_KEY_CONTA_FACIL',
    appId: '1:123456789:ios:abcdef',
    messagingSenderId: '123456789',
    projectId: 'conta-facil-demo',
    storageBucket: 'conta-facil-demo.appspot.com',
    iosBundleId: 'com.example.contaFacil',
  );
}
