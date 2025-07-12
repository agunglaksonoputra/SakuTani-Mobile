import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/input/field_selector.dart';
import '../../components/input/custom_date_field.dart';
import '../../components/input/custom_text_field.dart';
import '../../providers/expenses_record_provider.dart';

class ExpensesRecordScreen extends StatefulWidget {
  const ExpensesRecordScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesRecordScreen> createState() => _ExpensesRecordingScreenState();
}

class _ExpensesRecordingScreenState extends State<ExpensesRecordScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExpensesRecordProvider>(context, listen: false);
      provider.fetchOptions();
      provider.clearForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesRecordProvider>(
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
                          'Input Biaya',
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
          body: Consumer<ExpensesRecordProvider>(
            builder: (context, provider, child) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomDateField(
                        label: "Tanggal",
                        selectedDate: provider.selectedDate,
                        onDateSelected: (date) {
                          provider.selectedDate = date;
                          provider.notifyListeners();
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Nama',
                        controller: provider.nameController,
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
                              // onChanged: (value) {
                              //   provider.totalPriceController.text =
                              //       provider.totalPriceCount.truncate().toString();
                              //   provider.totalWeightPerKgController.text =
                              //       provider.totalWeightKgCount.toStringAsFixed(2);
                              // },
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FieldSelectorInput(
                              label: 'Satuan',
                              controller: provider.unitController,
                              options: provider.unitOptions,
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
                              // onChanged: (value) {
                              //   provider.totalPriceController.text =
                              //       provider.totalPriceCount.truncate().toString();
                              // },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Expanded(
                          //   child: CustomTextField(
                          //     label: 'Berat per Satuan (gram)',
                          //     controller: provider.weightPerUnitController,
                          //     keyboardType: TextInputType.number,
                          //     onChanged: (value) {
                          //       provider.totalWeightPerKgController.text =
                          //           provider.totalWeightKgCount.toStringAsFixed(1);
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Harga Ongkir',
                              controller: provider.shippingCostController,
                              keyboardType: TextInputType.number,
                              // onChanged: (value) {
                              //   provider.totalPriceController.text =
                              //       provider.totalPriceCount.truncate().toString();
                              // },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              label: 'Harga Diskon',
                              controller: provider.discountController,
                              keyboardType: TextInputType.number,
                              // onChanged: (value) {
                              //   provider.totalPriceController.text =
                              //       provider.totalPriceCount.truncate().toString();
                              // },
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
                              controller: provider.totalAmountController,
                              keyboardType: TextInputType.number,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Expanded(
                          //   child: CustomTextField(
                          //     label: 'Jumlah (kg)',
                          //     controller: provider.totalWeightPerKgController,
                          //     keyboardType: TextInputType.number,
                          //     isRequired: true,
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : () async {
                            final success = await provider.submitExpensesRecord();

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
                                        'Berhasil.',
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