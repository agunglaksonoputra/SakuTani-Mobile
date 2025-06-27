import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';

class SummaryCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        return Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: 'Total Penjualan',
                value: salesProvider.formatCurrency(salesProvider.summary.totalSales),
                color: Color(0xFF10B981),
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'Total Berat',
                value: '${salesProvider.summary.totalWeight.toInt()} Kg',
                color: Color(0xFF8B5CF6),
                textColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final Color textColor;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.color,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}