import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/periode_selector.dart';
import 'package:saku_tani_mobile/components/transaction_items/expenses_transaction_item.dart';
import 'package:saku_tani_mobile/components/summary_cards.dart';
import 'package:saku_tani_mobile/helper/role_permission_extension.dart';
import 'package:saku_tani_mobile/providers/expenses_provider.dart';
import 'package:saku_tani_mobile/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

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
    final auth = context.watch<AuthProvider>();

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
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),

                    // Action button (icon add)
                    (auth.role.canCreate)
                        ? GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.expensesRecord).then((_) {
                          Provider.of<ExpensesProvider>(context, listen: false).refreshData();
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(0xFFF43F5E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ) : SizedBox.shrink(),
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

            final data = provider.transactions;

            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              children: [
                PeriodeSelector(
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
                        canDelete: auth.role.canDelete,
                        onDelete: () {
                          _showDeleteDialog(context, transaction.id!);
                        },
                      ),
                    )),
                  if (provider.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (!provider.hasMore && data.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text("Semua data telah dimuat.")),
                    ),
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
      barrierDismissible: false, // agar tidak bisa ditutup manual saat loading
      builder: (context) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Konfirmasi'),
              content: isDeleting
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menghapus transaksi...'),
                ],
              )
                  : Text('Yakin ingin menghapus transaksi ini?'),
              actions: isDeleting
                  ? []
                  : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() => isDeleting = true);
                    await Provider.of<ExpensesProvider>(context, listen: false)
                        .deleteTransaction(transactionId);
                    Navigator.of(context).pop(); // Tutup dialog setelah selesai
                  },
                  child: Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}