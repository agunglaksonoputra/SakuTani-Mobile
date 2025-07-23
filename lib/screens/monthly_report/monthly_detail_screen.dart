import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/transaction_items/expenses_transaction_item.dart';
import 'package:saku_tani_mobile/components/transaction_items/sales_transaction_item.dart';
import 'package:saku_tani_mobile/models/expenses_transaction.dart';
import 'package:saku_tani_mobile/models/monthly_report_response.dart';
import 'package:saku_tani_mobile/models/sale_transaction.dart';
import '../../components/summary_cards.dart';
import '../../models/transaction_record.dart';
import '../../providers/monthly_report_provider.dart';

class MonthlyDetailScreen extends StatefulWidget {
  final MonthlyReportResponse data;

  const MonthlyDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<MonthlyDetailScreen> createState() => _MonthlyDetailScreenState();
}

class _MonthlyDetailScreenState extends State<MonthlyDetailScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.data.id;
      Provider.of<MonthlyReportProvider>(context, listen: false).fetchMonthlyDetail(id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Detail Laporan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Consumer<MonthlyReportProvider>(
          builder: (context, provider, _) {
            final transactions = provider.combinedTransactions;

            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Pendapatan',
                        value: provider.formatCurrencyInt(provider.totalSales),
                        color: Color(0xFF10B981),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Pengeluaran',
                        value: provider.formatCurrencyInt(provider.totalExpenses),
                        color: Color(0xFF8B5CF6),
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Daftar Transaksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      const FaIcon(
                        FontAwesomeIcons.fileCircleXmark,
                        size: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada laporan',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  )
                else
                  ...transactions.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: buildTransactionCard(item),
                  )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildTransactionCard(TransactionRecord item) {
    switch (item.type) {
      case TransactionType.sale:
        if (item.data is SaleTransaction) {
          return SalesTransactionItem(transaction: item.data as SaleTransaction);
          // return SalesTransactionCard(sale: item.data as SaleTransaction);
        } else {
          return const SizedBox(); // atau tampilkan error
        }

      case TransactionType.expense:
        if (item.data is ExpensesTransaction) {
          return ExpensesTransactionItem(transaction: item.data as ExpensesTransaction);
          // return ExpenseTransactionCard(expense: item.data as ExpenseModel);
        } else {
          return const SizedBox(); // atau tampilkan error
        }

      default:
        return const SizedBox(); // fallback untuk kasus tak terduga
    }
  }

}
