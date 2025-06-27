import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

class CashflowChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 200,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 4),
                      Text('Pendapatan', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 4),
                      Text('Pengeluaran', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: CustomPaint(
                  painter: CashflowChartPainter(provider.cashflowData),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CashflowChartPainter extends CustomPainter {
  final List<CashflowData> data;

  CashflowChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final maxValue = data.fold<double>(0, (max, item) =>
        [max, item.income, item.expense].reduce((a, b) => a > b ? a : b));

    final barWidth = size.width / (data.length * 2);

    for (int i = 0; i < data.length; i++) {
      final x = i * barWidth * 2;

      // Income bar
      paint.color = Colors.blue;
      final incomeHeight = (data[i].income / maxValue) * size.height;
      canvas.drawRect(
        Rect.fromLTWH(x, size.height - incomeHeight, barWidth * 0.8, incomeHeight),
        paint,
      );

      // Expense bar
      paint.color = Colors.orange;
      final expenseHeight = (data[i].expense / maxValue) * size.height;
      canvas.drawRect(
        Rect.fromLTWH(x + barWidth, size.height - expenseHeight, barWidth * 0.8, expenseHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}