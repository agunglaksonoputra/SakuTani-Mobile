import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';

class ExpensesTransactionItem extends StatelessWidget {
  final ExpensesTransaction transaction;
  final VoidCallback? onDelete;

  const ExpensesTransactionItem({
    Key? key,
    required this.transaction,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetailDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFF43F5E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FontAwesomeIcons.cartShopping,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.name ?? 'Pelanggan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.formattedDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.formatCurrency(transaction.totalAmount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
                if (onDelete != null) ...[
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      print('Icon delete ditekan');
                      onDelete?.call();
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        FontAwesomeIcons.trashCan,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transaction.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Detail Transaksi'),
        // insetPadding: EdgeInsets.symmetric(horizontal: 24),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FixedColumnWidth(2),
                2: FlexColumnWidth(),
              },
              children: [
                _buildTableRow('Tanggal', transaction.formattedDate),
                _buildTableRow('Nama', transaction.name ?? '-'),
                _buildTableRow('Jumlah', '${transaction.formatDouble(transaction.quantity)} ${transaction.unit}'),
                _buildTableRow('Harga per Unit', transaction.formatCurrency(transaction.pricePerUnit)),
                _buildTableRow('Ongkir', transaction.formatCurrency(transaction.shippingCost ?? 0)),
                _buildTableRow('Diskon', transaction.formatCurrency(transaction.discount ?? 0)),
                _buildTableRow('Total Harga', transaction.formatCurrency(transaction.totalAmount)),
                _buildTableRow('Catatan', transaction.notes ?? ''),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            '$label',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          child: Text(':', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Text(value),
        ),
      ],
    );
  }

}