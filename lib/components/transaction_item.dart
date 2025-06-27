import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../models/sale_transaction.dart';
import '../providers/sales_provider.dart';
import 'package:provider/provider.dart';

class TransactionItem extends StatelessWidget {
  final SaleTransaction transaction;
  final VoidCallback? onDelete;

  const TransactionItem({
    Key? key,
    required this.transaction,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    return Container(
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
                  color: Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  FontAwesomeIcons.cartShopping,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.customerName ?? 'Pelanggan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.date != null
                          ? DateFormat('d MMM yyyy').format(transaction.date!)
                          : '-',
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
                    salesProvider.formatCurrency(transaction.totalPrice ?? 0),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${transaction.quantity ?? 0} ${transaction.unit}/${transaction.totalWeightKg?.toStringAsFixed(2) ?? '0'} kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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
          if (transaction.itemName != null) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    transaction.itemName!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}