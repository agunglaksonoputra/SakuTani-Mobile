import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saku_tani_mobile/models/withdraw_response.dart';

import '../../models/withdraw_log.dart';

class WithdrawTransactionItem extends StatelessWidget {
  final WithdrawResponse? transaction;

  const WithdrawTransactionItem({
    Key? key,
    this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final salesProvider = Provider.of<SalesProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
        // color: Color(0xFF8B5CF6).withOpacity(0.1),
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(12),
        //   topRight: Radius.circular(12),
        // ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.04),
        //     offset: Offset(0, 2),
        //     blurRadius: 8,
        //   ),
        // ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction!.formattedDate,
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                    transaction?.formatCurrency(transaction?.totalAmount ?? 0) ?? 'null',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (transaction?.withdrawLog ?? [])
                  .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _widgetTransactionItem(item),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget  _widgetTransactionItem (WithdrawLog item) {
    return Container(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFF43F5E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              FontAwesomeIcons.handHoldingDollar,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.userName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.formattedDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),

              ],
            ),
          ),
          Text(
            '${item.formatCurrency(item.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (_isDeleted(item.date)) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {

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
                  size: 14,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isDeleted(DateTime? date) {
    // if (date == null) return false;
    // final now = DateTime.now();
    // final localDate = date.toLocal();
    // return localDate.year == now.year &&
    //     localDate.month == now.month &&
    //     localDate.day == now.day;
    if (date == null) return false;

    final now = DateTime.now();
    final localDate = date.toLocal();

    final difference = now.difference(localDate).inDays;

    return difference >= 0 && difference <= 3;
  }
}