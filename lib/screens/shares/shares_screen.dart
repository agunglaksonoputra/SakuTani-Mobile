import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/periode_selector.dart';
import 'package:saku_tani_mobile/providers/shares_provider.dart';
import '../../components/summary_cards.dart';
import '../../components/transaction_items/withdraw_transaction_item.dart';
import '../../routes/app_routes.dart';

class SharesScreen extends StatefulWidget {
  @override
  _SharesScreenState createState() => _SharesScreenState();
}

class _SharesScreenState extends State<SharesScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          final provider = Provider.of<SharesProvider>(context, listen: false);
          if (provider.hasMore && !provider.isLoadingMore) {
            provider.loadMoreWithdrawLog();
          }
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SharesProvider>(context, listen: false);
      provider.loadUserBalances();
      provider.loadMoreWithdrawLog();
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bagi Hasil',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.withdrawRecord).then((_) {
                          // Setelah halaman input ditutup, panggil refresh
                          Provider.of<SharesProvider>(context, listen: false).refreshData();
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
        child: Consumer<SharesProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.userBalances.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            final data = provider.filteredTransactions;

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
                  title: provider.zakatBalance.name,
                  value: provider.formatCurrency(provider.zakatBalance.balance),
                  color: Color(0xFFF43F5E),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: provider.otherUserBalances.map((user) {
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 44) / 2,
                      child: SummaryCard(
                        title: user.name,
                        value: provider.formatCurrency(user.balance),
                        color: Color(0xFF10B981),
                        textColor: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Transaksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
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
                    child: WithdrawTransactionItem(
                      transaction: transaction,
                      onDelete: () =>
                          _showDeleteDialog(context, transaction.id!),
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
                    await Provider.of<SharesProvider>(context, listen: false)
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
