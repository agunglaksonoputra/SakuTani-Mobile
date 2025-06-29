import 'package:flutter/material.dart';

import '../models/finance.dart';

class FinanceCard extends StatelessWidget {
  final FinanceData data;

  const FinanceCard({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Rp ${_formatNumber(data.amount)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.0,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );
  }
}