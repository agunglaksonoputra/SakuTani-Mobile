import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/providers/auth_provider.dart';
import 'package:saku_tani_mobile/providers/expenses_provider.dart';
import 'package:saku_tani_mobile/providers/expenses_record_provider.dart';
import 'package:saku_tani_mobile/providers/sales_record_provider.dart';
import 'package:saku_tani_mobile/screens/splash_screen.dart';
import 'package:saku_tani_mobile/services/dio_client.dart';
import 'providers/finance_provider.dart';
import 'providers/sales_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DioClient.initialize();
  await initializeDateFormatting('id_ID', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => SalesRecordProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpensesProvider()),
        ChangeNotifierProvider(create: (_) => ExpensesRecordProvider()),
      ],
      child: MaterialApp(
        navigatorKey: DioClient.navigatorKey,
        title: 'Saku Tani',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/', // Use actual Widget instead of String
        routes: AppRoutes.routes,
      ),
    );
  }
}