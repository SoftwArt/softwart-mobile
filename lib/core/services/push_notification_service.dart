// core/services/push_notification_service.dart
// Notificaciones push (Firebase Cloud Messaging).
// El backend envía al topic "staff"; la app se suscribe al iniciar sesión
// (Admin/Empleado), así no se guardan tokens por usuario.
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// Handler de mensajes en segundo plano — debe ser una función top-level.
// Con payload de notificación, Android muestra la notificación automáticamente.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService {
  static const String _staffTopic = 'staff';
  static final FirebaseMessaging _fm = FirebaseMessaging.instance;

  // Llave global para mostrar SnackBars al llegar un mensaje en primer plano.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Pide permiso y registra el listener de primer plano.
  // (El handler de segundo plano se registra en main.dart antes de runApp.)
  static Future<void> init() async {
    await _fm.requestPermission();
    FirebaseMessaging.onMessage.listen(_showForeground);
  }

  static void _showForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    final texto = [n.title, n.body].where((s) => s != null && s.isNotEmpty).join('\n');
    if (texto.isEmpty) return;
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: const Color(0xFF002926),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Suscribe/desuscribe el dispositivo al topic del personal.
  static Future<void> subscribeStaff() => _fm.subscribeToTopic(_staffTopic);
  static Future<void> unsubscribeStaff() => _fm.unsubscribeFromTopic(_staffTopic);
}
