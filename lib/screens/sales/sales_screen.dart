import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/periode_selector.dart';
import 'package:saku_tani_mobile/components/summary_cards.dart';
import 'package:saku_tani_mobile/components/transaction_items/sales_transaction_item.dart';
import 'package:saku_tani_mobile/screens/sales/sales_recording_screen.dart';
import '../../providers/sales_provider.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          final provider = Provider.of<SalesProvider>(context, listen: false);
          if (provider.hasMore && !provider.isLoadingMore) {
            provider.loadMoreData();
          }
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesProvider>(context, listen: false).refreshData();
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
                          'Penjualan',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SalesRecordingScreen(),
                          ),
                        ).then((_) {
                          // Setelah halaman input ditutup, panggil refresh
                          Provider.of<SalesProvider>(context, listen: false).refreshData();
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981),
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
        child: Consumer<SalesProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.transactions.isEmpty) {
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
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Penjualan',
                        value: provider.formatCurrency(provider.summary.totalSales),
                        color: Color(0xFF10B981),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Berat',
                        value: '${provider.summary.totalWeight.toInt()} kg',
                        color: Color(0xFF8B5CF6),
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Daftar Transaksi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...data.map((transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SalesTransactionItem(
                    transaction: transaction,
                    onDelete: () {
                      _showDeleteDialog(context, transaction.id!);
                    },
                  ),
                )),
                if (provider.isLoadingMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (!provider.hasMore && data.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                    await Provider.of<SalesProvider>(context, listen: false)
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