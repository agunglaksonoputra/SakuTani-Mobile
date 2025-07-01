import 'package:flutter/material.dart';
import 'package:saku_tani_mobile/screens/auth/login_screen.dart';
import 'package:saku_tani_mobile/screens/expenses/expenses_record_screen.dart';
import 'package:saku_tani_mobile/screens/expenses/expenses_screen.dart';
import 'package:saku_tani_mobile/screens/main_screen.dart';
import 'package:saku_tani_mobile/screens/sales/sales_screen.dart';
import 'package:saku_tani_mobile/screens/splash_screen.dart';
import '../components/reports_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String main = '/main';
  static const String splashScreen = '/';
  static const String sales = '/sales';
  static const String expenses = '/expenses';
  static const String expensesRecord = '/expenses/record';

  static Map<String, WidgetBuilder> routes = {

    splashScreen: (context) => SplashScreen(),
    main: (context) => MainScreen(),
    home: (context) => HomeScreen(),
    reports: (context) => ReportsScreen(),
    settings: (context) => SettingsScreen(),
    login: (context) => LoginScreen(),
    sales: (context) => SalesScreen(),
    expenses: (context) => ExpensesScreen(),
    expensesRecord: (context) => ExpensesRecordScreen(),

  };
}