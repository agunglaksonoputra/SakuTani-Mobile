import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';

class PeriodSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, _) {
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  salesProvider.clearDateFilter();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: salesProvider.selectedDateRange == null
                        ? Color(0xFFE0E7FF)
                        : Colors.white,
                    border: Border.all(
                      color: salesProvider.selectedDateRange == null
                          ? Color(0xFF6366F1)
                          : Color(0xFFE5E7EB),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Semua',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: salesProvider.selectedDateRange == null
                          ? Color(0xFF6366F1)
                          : Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2022),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    salesProvider.setDateFilter(picked);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: salesProvider.selectedDateRange != null
                        ? Color(0xFFE0E7FF)
                        : Colors.white,
                    border: Border.all(
                      color: salesProvider.selectedDateRange != null
                          ? Color(0xFF6366F1)
                          : Color(0xFFE5E7EB),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    salesProvider.selectedDateRange != null
                        ? 'Filter Tanggal'
                        : 'Tanggal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: salesProvider.selectedDateRange != null
                          ? Color(0xFF6366F1)
                          : Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}