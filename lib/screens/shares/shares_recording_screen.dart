import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:saku_tani_mobile/components/custom_text_field.dart';
import 'package:saku_tani_mobile/components/field_selector.dart';
import '../../components/custom_text_field_button.dart';
import '../../providers/shares_record_provider.dart';

class WithdrawRecordScreen extends StatefulWidget {
  const WithdrawRecordScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawRecordScreen> createState() => _WithdrawRecordScreenState();
}

class _WithdrawRecordScreenState extends State<WithdrawRecordScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SharesRecordProvider>(context, listen: false);
      provider.fetchOptions();
      provider.loadUserBalances();
      provider.clearForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SharesRecordProvider> (
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
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Input Pembayaran Bagi Hasil',
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
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    FieldSelectorInput(
                      label: 'Nama',
                      controller: provider.nameController,
                      options: provider.ownerOptions,
                      isRequired: true,
                      readOnly: true,
                      onChanged: (_) => provider.notifyListeners(),
                    ),
                    const SizedBox(height: 20),
                    CustomTextFieldWithMax(
                      label: "Jumlah",
                      controller: provider.amountController,
                      keyboardType: TextInputType.number,
                      maxValue: provider.selectedUserBalance?.balance ?? 0.0,
                      userBalance: provider.selectedUserBalance?.balance ?? 0.0,
                      isRequired: true,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : () async {
                          final success = await provider.submitWithdrawRecord();

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
            ),
          );
        }
    );
  }
}