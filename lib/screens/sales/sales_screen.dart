import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/period_selector.dart';
import 'package:saku_tani_mobile/components/summary_cards.dart';
import 'package:saku_tani_mobile/providers/sales_record_provider.dart';
import 'package:saku_tani_mobile/screens/sales/sales_recording_screen.dart';

import '../../components/transaction_item.dart';
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
      Provider.of<SalesProvider>(context, listen: false).fetchInitialData();
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
                          Provider.of<SalesProvider>(context, listen: false).fetchInitialData();
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

            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: data.length + 6 + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) return PeriodSelector();
                if (index == 1) return SizedBox(height: 20);
                if (index == 2) return SummaryCards();
                if (index == 3) return SizedBox(height: 24);
                if (index == 4) {
                  return Text(
                    'Daftar Transaksi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  );
                }
                if (index == 5) return SizedBox(height: 12);

                final transactionIndex = index - 6;
                if (transactionIndex < data.length) {
                  final transaction = data[transactionIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TransactionItem(
                      transaction: transaction,
                      onDelete: () {
                        _showDeleteDialog(context, transaction.id!);
                      },
                    ),
                  );
                }

                if (provider.isLoadingMore) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!provider.hasMore) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: Text("Semua data telah dimuat.")),
                  );
                }

                return SizedBox();
              },
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