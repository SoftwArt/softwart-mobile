// core/utils/alert_prefs.dart
// Persiste los ids de alertas "ignoradas" del dashboard (como la web en
// localStorage). Llaves: ign_ventas / ign_citas / ign_pedidos.
import 'package:shared_preferences/shared_preferences.dart';

class AlertPrefs {
  static Future<Set<String>> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(key) ?? <String>[]).toSet();
  }

  static Future<void> add(String key, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(key) ?? <String>[];
    if (!list.contains(id)) {
      list.add(id);
      await prefs.setStringList(key, list);
    }
  }
}
