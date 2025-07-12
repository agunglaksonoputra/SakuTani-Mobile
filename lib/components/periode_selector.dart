import 'package:flutter/material.dart';

class PeriodeSelector extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final VoidCallback onClear;
  final Function(DateTimeRange) onSelect;

  const PeriodeSelector({
    super.key,
    required this.selectedRange,
    required this.onClear,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedRange == null
                    ? const Color(0xFFE0E7FF)
                    : Colors.white,
                border: Border.all(
                  color: selectedRange == null
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Semua',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selectedRange == null
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2022),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onSelect(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedRange != null
                    ? const Color(0xFFE0E7FF)
                    : Colors.white,
                border: Border.all(
                  color: selectedRange != null
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selectedRange != null ? 'Filter Tanggal' : 'Tanggal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selectedRange != null
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}