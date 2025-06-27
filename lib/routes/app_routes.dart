import 'package:flutter/material.dart';
import '../components/reports_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String reports = '/reports';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    // home: (context) => HomeScreen(),
    reports: (context) => ReportsScreen(),
    settings: (context) => SettingsScreen(),
  };
}