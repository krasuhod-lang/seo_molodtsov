import 'package:shared_preferences/shared_preferences.dart';

/// Хранение признака первого запуска (для onboarding).
class PrefsService {
  static const String _kOnboardingShown = 'onboarding_shown_v1';

  Future<bool> isOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingShown) ?? false;
  }

  Future<void> markOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingShown, true);
  }
}
