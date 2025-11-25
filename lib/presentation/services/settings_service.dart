import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _waterReminderKey = 'water_reminder_active';

  // Guarda el estado del recordatorio de agua
  Future<void> setWaterReminder(bool isActive) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_waterReminderKey, isActive);
  }

  // Lee el estado del recordatorio de agua
  Future<bool> getWaterReminder() async {
    final prefs = await SharedPreferences.getInstance();
    // Devuelve el valor guardado, o 'false' si nunca se ha guardado nada.
    return prefs.getBool(_waterReminderKey) ?? false;
  }
}