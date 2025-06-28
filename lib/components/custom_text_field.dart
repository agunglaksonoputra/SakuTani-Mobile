import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final bool isRequired;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.initialValue,
    this.isRequired = false
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
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFF8B5CF6).withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
      ],
    );
  }
}