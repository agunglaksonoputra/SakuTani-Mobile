import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/period_selector.dart';
import '../providers/sales_provider.dart';
import '../components/summary_cards.dart';
import '../components/transaction_item.dart';

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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.angleLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Penjualan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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
                        provider.deleteTransaction(transaction.id!);
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
}