import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app-wide settings: theme mode, language preference, and app version.
///
/// Persists theme mode in SharedPreferences so it survives app restarts.
/// Language is handled via easy_localization; this provider only exposes
/// the current locale for display purposes.
class SettingsProvider extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  String _appVersion = '';
  String _buildNumber = '';

  ThemeMode get themeMode => _themeMode;
  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;
  String get fullVersion => '$_appVersion+$_buildNumber';

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    // Load persisted theme mode
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModeKey);
    if (saved != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
    }

    // Load app version from pubspec
    final info = await PackageInfo.fromPlatform();
    _appVersion = info.version;
    _buildNumber = info.buildNumber;

    notifyListeners();
  }

  /// Updates theme mode and persists the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }
}
