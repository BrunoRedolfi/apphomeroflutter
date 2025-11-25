import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Hacemos la clase un Singleton para tener una única instancia en toda la app.
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Configuración de inicialización para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Usa el icono de tu app

    // 2. Configuración de inicialización para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // 3. Juntamos las configuraciones
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 4. Inicializamos el plugin y la configuración de zonas horarias
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  // Método para programar notificaciones periódicas
  Future<void> scheduleHourlyWaterReminder() async {
    // Pide permiso para notificaciones en Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Detalles de la notificación
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'water_reminder_channel', // ID del canal
      'Recordatorio de Agua',   // Nombre del canal
      channelDescription: 'Canal para recordatorios de beber agua.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    // Programamos la notificación para que se repita cada hora
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0, // ID de la notificación
      "¡Hora de hidratarse!",
      "Mmm... agüita. ¡Bebe un vaso de agua!",
      RepeatInterval.everyMinute, // ¡Se repite cada hora!
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // <-- ¡Este es el cambio!
    );
  }

  // Método para cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}