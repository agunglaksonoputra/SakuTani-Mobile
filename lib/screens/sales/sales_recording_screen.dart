import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/custom_text_field.dart';
import 'package:saku_tani_mobile/components/field_selector.dart';
import 'package:saku_tani_mobile/providers/sales_record_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SalesRecordingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SalesRecordingScreen extends StatefulWidget {
  const SalesRecordingScreen({Key? key}) : super(key: key);

  @override
  State<SalesRecordingScreen> createState() => _SalesRecordingScreenState();
}

class _SalesRecordingScreenState extends State<SalesRecordingScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SalesRecordProvider>(
      builder: (context, provider, _) {
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
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
                          onPressed: () => Navigator.pop(context), // Tetap bisa pakai ini
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Input Penjualan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
          body: Consumer<SalesRecordProvider>(
            builder: (context, provider, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FieldSelectorInput(
                        label: 'Pelanggan',
                        controller: provider.customerController,
                        options: ['Agung', 'Toni', 'Budi'],
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),
                      FieldSelectorInput(
                        label: 'Sayuran',
                        controller: provider.vegetableController,
                        options: ['Kangkung', 'Sawi', 'Bayam'],
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Jumlah (pcs)',
                              controller: provider.quantityController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                provider.totalPriceController.text =
                                    provider.totalPriceCount.truncate().toString();
                                provider.totalWeightPerKgController.text =
                                    provider.totalWeightKgCount.toStringAsFixed(2);
                              },
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FieldSelectorInput(
                              label: 'Satuan',
                              controller: provider.unitController,
                              options: ['kg', 'pcs'],
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Harga Satuan',
                              controller: provider.pricePerUnitController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                provider.totalPriceController.text =
                                    provider.totalPriceCount.truncate().toString();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Berat per Satuan (gram)',
                              controller: provider.weightPerUnitController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                provider.totalWeightPerKgController.text =
                                    provider.totalWeightKgCount.toStringAsFixed(1);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Keterangan',
                        controller: provider.noteController,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Total Harga',
                              controller: provider.totalPriceController,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Jumlah (kg)',
                              controller: provider.totalWeightPerKgController,
                              keyboardType: TextInputType.number,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : () async {
                            final success = await provider.submitSalesRecord();

                            if (success) {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.circleCheck, // Regular check icon
                                        color: Colors.green,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Data berhasil disimpan.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(FontAwesomeIcons.exclamationCircle, color: Colors.redAccent, size: 48),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Gagal Menyimpan',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        provider.errorMessage ?? 'Terjadi kesalahan saat mengirim data. Pastikan semua field telah diisi dengan benar.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Tutup',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}