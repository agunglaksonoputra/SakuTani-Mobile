import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';

class ProfitShareList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        print("Jumlah profit shares: ${provider.profitShares.length}");
        return Column(
          children: provider.profitShares.map((share) {
            return Container(
              margin: EdgeInsets.only(bottom: 8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        share.name,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Saldo Tersedia',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rp ${_formatNumber(share.amount)}',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}