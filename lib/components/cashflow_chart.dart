import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/finance.dart';
import '../providers/finance_provider.dart';

class CashflowChart extends StatelessWidget {
  const CashflowChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        final data = provider.cashflowData;
        if (data.isEmpty) {
          return const Center(child: Text('Tidak ada data'));
        }

        // Membalik data agar data terbaru tampil di sebelah kiri
        final reversedData = data.reversed.toList();

        final maxValue = reversedData.fold<double>(
          0,
              (max, item) =>
              [max, item.income, item.expense].reduce((a, b) => a > b ? a : b),
        );

        return Container(
          height: 400,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                  _buildLegend(const Color(0xFF10B981), 'Pendapatan'),
                  const SizedBox(width: 20),
                  _buildLegend(const Color(0xFFF43F5E), 'Pengeluaran'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: maxValue * 1.3,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= reversedData.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                reversedData[index].label,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                NumberFormat.compact(locale: 'id_ID').format(value),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(enabled: true),
                    barGroups: _generateBarGroups(reversedData),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<CashflowData> data) {
    return List.generate(data.length, (index) {
      final item = data[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.income,
            width: 8,
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: item.expense,
            width: 8,
            color: const Color(0xFFF43F5E),
            borderRadius: BorderRadius.zero,
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
