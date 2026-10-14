import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  bool darkMode = false;
  bool notifications = true;
  bool journeyReminders = true;

  void setDarkMode(bool value) {
    darkMode = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    notifications = value;
    notifyListeners();
  }

  void setJourneyReminders(bool value) {
    journeyReminders = value;
    notifyListeners();
  }
}

class SettingsScope extends InheritedNotifier<AppSettings> {
  const SettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);
  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}
