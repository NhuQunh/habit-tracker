import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/services/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.vietnamese;
  bool _isLoading = true;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;
  Locale get locale => _currentLanguage == AppLanguage.english
      ? const Locale('en')
      : const Locale('vi');

  LocalizationProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langStr = prefs.getString('app_language') ?? 'vi';
    _currentLanguage = langStr == 'en' ? AppLanguage.english : AppLanguage.vietnamese;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;

    final prefs = await SharedPreferences.getInstance();
    final langStr = language == AppLanguage.english ? 'en' : 'vi';
    await prefs.setString('app_language', langStr);

    _currentLanguage = language;
    notifyListeners();
  }

  String translate(String key) {
    return LocalizationService.translate(key, _currentLanguage);
  }
}