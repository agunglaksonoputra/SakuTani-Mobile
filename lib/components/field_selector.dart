import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FieldSelectorInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> options;
  final bool isRequired;

  const FieldSelectorInput({
    super.key,
    required this.label,
    required this.controller,
    required this.options,
    this.isRequired = false
  });

  @override
  Widget build(BuildContext context) {
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
          decoration: InputDecoration(
            // hintText: 'Pilih atau ketik...',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFF8B5CF6).withOpacity(0.2), // warna border
                width: 2.0,         // ketebalan border (opsional)
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Color(0xFF8B5CF6).withOpacity(1),
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: Color(0xFF8B5CF6).withOpacity(0.1),
            suffixIcon: IconButton(
              icon: const Icon(FontAwesomeIcons.angleDown),
              onPressed: () => _showOptionBottomSheet(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Pilih $label',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...options.map((option) => ListTile(
                  title: Text(option),
                  onTap: () {
                    controller.text = option;
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}