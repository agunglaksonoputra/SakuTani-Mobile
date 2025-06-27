import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MonthlyBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        return IntrinsicHeight( // Tambahkan ini
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // ini penting
            children: [
              Expanded(
                child: _buildBreakdownCard(
                  'Pendapatan Bulan Ini',
                  provider.monthlyData['Pendapatan Bulan Ini']!,
                  Colors.green,
                  FontAwesomeIcons.arrowTrendUp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBreakdownCard(
                  'Pengeluaran Bulan Ini',
                  provider.monthlyData['Pengeluaran Bulan Ini']!,
                  Colors.pink,
                  FontAwesomeIcons.arrowTrendDown,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownCard(
      String title,
      List<Map<String, dynamic>> items,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'],
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Rp ${_formatNumber(item['amount'])}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )).toList(),
          )
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}
