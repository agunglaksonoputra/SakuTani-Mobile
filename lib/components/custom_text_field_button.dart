import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'custom_text_field.dart';

class CustomTextFieldWithMax extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final bool isRequired;
  final double? maxValue;
  final double? userBalance;

  const CustomTextFieldWithMax({
    Key? key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.initialValue,
    this.isRequired = false,
    this.maxValue,
    this.userBalance = null,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initialValue != null &&
        controller.text.isEmpty &&
        controller.text != initialValue) {
      controller.text = initialValue!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                children: isRequired
                    ? [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  )
                ]
                    : [],
              ),
            ),

            if (userBalance != null)
              Text(
                'Saldo: ${NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0).format(userBalance)}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              )
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              inputFormatters: keyboardType == TextInputType.number
                  ? [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ThousandsSeparatorInputFormatter(),
              ]
                  : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF8B5CF6).withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ).copyWith(right: 60), // beri ruang untuk tombol Max
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFF8B5CF6).withOpacity(0.2),
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color(0xFF8B5CF6),
                    width: 2.0,
                  ),
                ),
              ),
            ),
            if (maxValue != null)
              Positioned(
                right: 12,
                child: TextButton(
                  onPressed: () {
                    final formatted =
                    NumberFormat("#,##0.##", "id").format(maxValue);
                    controller.text = formatted;
                    if (onChanged != null) {
                      onChanged!(formatted);
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Max',
                    style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
