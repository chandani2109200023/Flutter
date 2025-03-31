import 'dart:html' as html;

class StorageService {
  static Future<void> setItem(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  static Future<String?> getItem(String key) async {
    return html.window.localStorage[key];
  }

  static Future<void> removeItem(String key) async {
    html.window.localStorage.remove(key);
  }

  static Future<void> clear() async {
    html.window.localStorage.clear();
  }
}
