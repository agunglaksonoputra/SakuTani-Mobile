import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/cashflow_chart.dart';
import '../components/finance_card.dart';
import '../components/profit_share_list.dart';
import '../components/shortcut_grid.dart';
import '../providers/finance_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(context, listen: false).refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'SakuTani',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Consumer<FinanceProvider>(
          builder: (context, provider, child) {
            return provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Month
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child:  FinanceCard(data: provider.financeCards[0]),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: FinanceCard(data: provider.financeCards[1]),
                          ),
                          const SizedBox(width: 12), // jarak antar kartu
                          Expanded(
                            child: FinanceCard(data: provider.financeCards[2]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),

                  // Shortcuts
                  const Text(
                    'Pintasan',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ShortcutGrid(),

                  const SizedBox(height: 24.0),

                  // Profit Share Section
                  const Text(
                    'Bagi Hasil',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ProfitShareList(),

                  const SizedBox(height: 24.0),

                  // Cashflow Chart
                  const Text(
                    'Proyeksi Cashflow',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  CashflowChart(),

                  const SizedBox(height: 24.0),

                  // Monthly Breakdown (kalau nanti dipakai)
                  // const MonthlyBreakdown(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}