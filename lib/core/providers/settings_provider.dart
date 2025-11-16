import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gestionar las configuraciones de la aplicación
/// Maneja el tema (claro/oscuro/sistema) y el idioma (español/inglés)
class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('es', '');

  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  /// Inicializar configuraciones desde SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // Cargar tema
    final themeModeString = prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      _themeMode = _parseThemeMode(themeModeString);
    }

    // Cargar idioma
    final localeString = prefs.getString(_localeKey);
    if (localeString != null) {
      _locale = _parseLocale(localeString);
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Cambiar el modo de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.toString());
  }

  /// Cambiar el idioma
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.toString());
  }

  /// Parsear ThemeMode desde string
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }

  /// Parsear Locale desde string
  Locale _parseLocale(String value) {
    if (value.startsWith('en')) {
      return const Locale('en', '');
    }
    return const Locale('es', '');
  }

  /// Obtener el nombre legible del modo de tema
  String getThemeModeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Modo Claro';
      case ThemeMode.dark:
        return 'Modo Oscuro';
      case ThemeMode.system:
        return 'Predeterminado del Sistema';
    }
  }

  /// Obtener el nombre legible del idioma
  String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
      default:
        return 'Español';
    }
  }

  /// Obtener icono para el modo de tema
  IconData getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Obtener icono para el idioma
  IconData getLocaleIcon(Locale locale) {
    return Icons.language;
  }
}
