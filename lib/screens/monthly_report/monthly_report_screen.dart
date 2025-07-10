import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/monthly_report_item.dart';
import 'package:saku_tani_mobile/providers/monthly_report_provider.dart';
import '../../models/monthly_report_response.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MonthlyReportProvider>(context, listen: false).fetchInitialData();
    });
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
                          'Laporan Bulanan',
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
                        Provider.of<MonthlyReportProvider>(context, listen: false).downloadExcelFile(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FontAwesomeIcons.download,
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
        child: Consumer<MonthlyReportProvider> (
          builder: (context, provider, _) {
            if (provider.isLoading && provider.monthlyReports.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            final data = provider.monthlyReports;

            return ListView(
              // controller: _scrollController,
              padding: EdgeInsets.all(16),
              children: [
                const Text(
                  'Daftar Laporan',
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
                        'Tidak ada laporan',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  )
                else
                  ...data.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: MonthlyReportItem(monthlyReports: item)
                  )),

              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportItem(MonthlyReportResponse item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(FontAwesomeIcons.calendar),
        title: Text(item.formattedDate ?? 'Bulan tidak diketahui'),
        subtitle: Text('Pendapatan: ${item.formatCurrency(item.totalSales)}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Aksi ketika diklik, misal tampilkan detail
        },
      ),
    );
  }

}