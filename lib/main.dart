import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/providers/sales_record_provider.dart';
import 'providers/finance_provider.dart';
import 'providers/sales_provider.dart';
import 'routes/app_routes.dart';
import 'screens/main_screen.dart'; // ⬅️ Import MainScreen yang dipisah

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
      ],
      child: MaterialApp(
        title: 'Saku Tani',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
        ),
        home: MainScreen(), // ⬅️ Entry point UI-nya
        routes: AppRoutes.routes,
      ),
    );
  }
}