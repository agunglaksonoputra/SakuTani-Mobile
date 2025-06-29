import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/finance.dart';
import '../providers/finance_provider.dart';
import 'dart:ui' as ui;

class CashflowChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        final chartData = provider.cashflowData;

        return Container(
          height: 240,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(Colors.blue, 'Pendapatan'),
                  SizedBox(width: 20),
                  _buildLegend(Colors.orange, 'Pengeluaran'),
                ],
              ),
              SizedBox(height: 16),

              // Chart
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      painter: CashflowChartPainter(
                        chartData,
                        availableWidth: constraints.maxWidth,
                      ),
                      size: Size(constraints.maxWidth, 200),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class CashflowChartPainter extends CustomPainter {
  final List<CashflowData> data;
  final double availableWidth;

  CashflowChartPainter(this.data, {required this.availableWidth});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final textStyle = TextStyle(color: Colors.black, fontSize: 10);
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );

    final paddingBottom = 30.0;
    final paddingLeft = 40.0;
    final chartHeight = size.height - paddingBottom;
    final chartWidth = size.width - paddingLeft;

    final maxValue = data.fold<double>(
      0,
          (max, item) => [max, item.income, item.expense].reduce((a, b) => a > b ? a : b),
    );

    final groupCount = data.length;
    final groupSpacing = chartWidth / (groupCount + 1); // +1 to add a bit of spacing on right
    final barWidth = groupSpacing / 2.5;

    // Garis bantu Y
    final step = maxValue / 4;
    for (int i = 0; i <= 4; i++) {
      final yValue = step * i;
      final y = chartHeight - (yValue / maxValue * chartHeight);

      // Line
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width, y),
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 1,
      );

      // Label Y
      textPainter.text = TextSpan(
        text: NumberFormat.compact(locale: 'id_ID').format(yValue),
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft - textPainter.width - 6, y - 6));
    }

    // Bars
    for (int i = 0; i < data.length; i++) {
      final xGroup = paddingLeft + (i + 1) * groupSpacing;

      // Income
      paint.color = Colors.blue;
      final incomeHeight = (data[i].income / maxValue) * chartHeight;
      canvas.drawRect(
        Rect.fromLTWH(xGroup - barWidth, chartHeight - incomeHeight, barWidth, incomeHeight),
        paint,
      );

      // Expense
      paint.color = Colors.orange;
      final expenseHeight = (data[i].expense / maxValue) * chartHeight;
      canvas.drawRect(
        Rect.fromLTWH(xGroup + 2, chartHeight - expenseHeight, barWidth, expenseHeight),
        paint,
      );

      // Label tanggal
      textPainter.text = TextSpan(text: data[i].label, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xGroup - textPainter.width / 2, chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
