import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/expenses_transaction_item.dart';
import 'package:saku_tani_mobile/components/summary_cards.dart';
import 'package:saku_tani_mobile/providers/expenses_provider.dart';
import 'package:saku_tani_mobile/routes/app_routes.dart';
import '../../components/period_selector.dart';


class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          final provider = Provider.of<ExpensesProvider>(context, listen: false);
          if (provider.hasMore && !provider.isLoadingMore) {
            provider.loadMoreData();
          }
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpensesProvider>(context, listen: false).refreshData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Leading icon
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Biaya',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    // Action button (icon add)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.expensesRecord).then((_) {
                          // Setelah halaman input ditutup, panggil refresh
                          Provider.of<ExpensesProvider>(context, listen: false).refreshData();
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFF43F5E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                          size: 20,
                        ),
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
        child: Consumer<ExpensesProvider> (
          builder: (context, provider, _) {
            if (provider.isLoading && provider.transactions.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            final data = provider.filteredTransactions;

            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              children: [
                PeriodSelector(
                  selectedRange: provider.selectedDateRange,
                  onClear: provider.clearDateFilter,
                  onSelect: (range) => provider.setDateFilter(range),
                ),
                const SizedBox(height: 20),
                SummaryCard(
                  title: 'Total Pengeluaran',
                  value: provider.formatCurrency(
                    (provider.summary['totalAmount'] ?? 0).toDouble(),
                  ),
                  color: Color(0xFFF43F5E),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Transaksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...[
                  if (data.isEmpty)
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
                          'Tidak ada transaksi',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    )
                  else
                    ...data.map((transaction) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ExpensesTransactionItem(
                        transaction: transaction,
                        onDelete: () {
                          _showDeleteDialog(context, transaction.id!);
                        },
                      ),
                    )),
                ],

              ],
            );
          },
        ),
      ),

    );
  }

  void _showDeleteDialog(BuildContext context, int transactionId) {
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
              Provider.of<ExpensesProvider>(context, listen: false)
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