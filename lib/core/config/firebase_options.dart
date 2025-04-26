import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'No se ha configurado Firebase Web - agregar configuración web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'No se ha configurado Firebase macOS - agregar configuración macOS',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'No se ha configurado Firebase Windows - agregar configuración Windows',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'No se ha configurado Firebase Linux - agregar configuración Linux',
        );
      default:
        throw UnsupportedError(
          'Plataforma no soportada: ${defaultTargetPlatform}',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'tu-api-key',
    appId: 'tu-app-id',
    messagingSenderId: 'tu-messaging-sender-id',
    projectId: 'tu-project-id',
    storageBucket: 'tu-storage-bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'tu-api-key',
    appId: 'tu-app-id',
    messagingSenderId: 'tu-messaging-sender-id',
    projectId: 'tu-project-id',
    storageBucket: 'tu-storage-bucket',
    iosClientId: 'tu-ios-client-id',
    iosBundleId: 'dev.stepup.windwaker',
  );
} 