import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/sales/sales_screen.dart';

class ShortcutGrid extends StatelessWidget {
  final List<Map<String, dynamic>> shortcuts = [
    {
      'icon': FontAwesomeIcons.fileCirclePlus,
      'label': 'Penjualan',
      'color': Colors.purple,
      'route': 'sales',
    },
    {
      'icon': FontAwesomeIcons.fileCircleMinus,
      'label': 'Biaya',
      'color': Colors.red,
      'route': 'expenses',
    },
    {
      'icon': FontAwesomeIcons.chartPie,
      'label': 'Bagi Hasil',
      'color': Colors.green,
      'route': 'sharing',
    },
    {
      'icon': FontAwesomeIcons.chartSimple,
      'label': 'Laporan',
      'color': Colors.blue,
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
            // Navigasi berdasarkan route atau langsung ke widget
            if (shortcut['route'] == 'sales') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesScreen(),
                ),
              );
            } else if (shortcut['route'] == 'expenses') {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => ExpensesScreen()),
              // );
            } else if (shortcut['route'] == 'sharing') {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => ProfitSharingScreen()),
              // );
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
