import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saku_tani_mobile/models/withdraw_response.dart';

class WithdrawTransactionItem extends StatelessWidget {
  final WithdrawResponse transaction;
  final VoidCallback? onDelete;

  const WithdrawTransactionItem({
    Key? key,
    required this.transaction,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    return Column(
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
                FontAwesomeIcons.percent,
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
            Text(
              '${transaction.formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 8),
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
        // if (transaction.notes != null) ...[
        //   SizedBox(height: 12),
        //   Row(
        //     children: [
        //       Icon(
        //         Icons.inventory_2_outlined,
        //         size: 16,
        //         color: Color(0xFF6B7280),
        //       ),
        //       const SizedBox(width: 8),
        //       Expanded(
        //         child: Text(
        //           transaction.name!,
        //           style: TextStyle(
        //             fontSize: 14,
        //             color: Color(0xFF4B5563),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ],
        // if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
        //   SizedBox(height: 8),
        //   Row(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Icon(
        //         Icons.note_outlined,
        //         size: 16,
        //         color: Color(0xFF6B7280),
        //       ),
        //       const SizedBox(width: 8),
        //       Expanded(
        //         child: Text(
        //           transaction.notes!,
        //           style: TextStyle(
        //             fontSize: 12,
        //             color: Color(0xFF6B7280),
        //             fontStyle: FontStyle.italic,
        //           ),
        //           maxLines: 1,
        //           overflow: TextOverflow.ellipsis,
        //         ),
        //       ),
        //     ],
        //   ),
        // ],
      ],
    );
  }
}