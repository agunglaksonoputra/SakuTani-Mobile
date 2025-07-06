import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/providers/finance_provider.dart';
import 'package:saku_tani_mobile/routes/app_routes.dart';
import '../screens/sales/sales_screen.dart';

class ShortcutGrid extends StatelessWidget {
  final List<Map<String, dynamic>> shortcuts = [
    {
      'icon': FontAwesomeIcons.fileCirclePlus,
      'label': 'Penjualan',
      'color': Color(0xFF8B5CF6),
      'route': 'sales',
    },
    {
      'icon': FontAwesomeIcons.fileCircleMinus,
      'label': 'Biaya',
      'color': Color(0xFFF43F5E),
      'route': 'expenses',
    },
    {
      'icon': FontAwesomeIcons.chartPie,
      'label': 'Bagi Hasil',
      'color': Color(0xFF10B981),
      'route': 'sharing',
    },
    {
      'icon': FontAwesomeIcons.chartSimple,
      'label': 'Laporan',
      'color': Color(0xFF8B5CF6),
      'route': 'report',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: shortcuts.map((shortcut) {
        return InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            if (shortcut['route'] == 'sales') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesScreen(),
                ),
              ).then((_) {
                Provider.of<FinanceProvider>(context, listen: false).refreshAll();
              });
            } else if (shortcut['route'] == 'expenses') {
              Navigator.pushNamed(context, AppRoutes.expenses).then((_) {
                Provider.of<FinanceProvider>(context, listen: false).refreshAll();
              });
            } else if (shortcut['route'] == 'sharing') {
              Navigator.pushNamed(context, AppRoutes.bagiHasil).then((_) {
                Provider.of<FinanceProvider>(context, listen: false).refreshAll();
              });
            } else if (shortcut['route'] == 'report') {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => ReportScreen()),
              // );
            }
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: shortcut['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  shortcut['icon'],
                  color: shortcut['color'],
                  size: 24.0,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                shortcut['label'],
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}