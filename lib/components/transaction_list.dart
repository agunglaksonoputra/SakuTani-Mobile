import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import 'transaction_item.dart';

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        final transactions = salesProvider.transactions;

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(height: 16),
                Text(
                  'Belum ada transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '${transactions.length} transaksi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                return TransactionItem(
                  transaction: transactions[index],
                  onDelete: () {
                    print('Memanggil _showDeleteDialog');
                    _showDeleteDialog(context, transactions[index].id!);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int transactionId) {
    print('Memunculkan dialog untuk ID $transactionId'); // log untuk debugging
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Transaksi'),
        content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<SalesProvider>(context, listen: false)
                  .deleteTransaction(transactionId);
              Navigator.pop(context);
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}