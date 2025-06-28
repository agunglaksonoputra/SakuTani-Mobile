import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/cashflow_chart.dart';
import '../components/finance_card.dart';
import '../components/monthly_breakdown.dart';
import '../components/profit_share_list.dart';
import '../components/shortcut_grid.dart';
import '../providers/finance_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Align(
              alignment: Alignment.centerLeft, // ⬅️ start horizontal, center vertical
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

      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Finance Cards Grid
              Consumer<FinanceProvider>(
                builder: (context, provider, child) {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemCount: provider.financeCards.length,
                    itemBuilder: (context, index) {
                      return FinanceCard(
                        data: provider.financeCards[index],
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 24.0),

              // Shortcuts
              Text(
                'Pintasan',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              ShortcutGrid(),

              const SizedBox(height: 24.0),

              // Profit Share Section
              Text(
                'Bagi Hasil',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              ProfitShareList(),

              const SizedBox(height: 24.0),

              // Cashflow Chart
              Text(
                'Proyeksi Cashflow 30 Hari',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12.0),
              CashflowChart(),

              const SizedBox(height: 24.0),

              // Monthly Breakdown
              MonthlyBreakdown(),
            ],
          ),
        ),
      ),
    );
  }
}