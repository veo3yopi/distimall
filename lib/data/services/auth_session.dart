import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  static const _manualLoginKey = 'manual_login_active';

  static Future<void> setManualLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_manualLoginKey, value);
  }

  static Future<bool> isManualLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_manualLoginKey) ?? false;
  }
}
