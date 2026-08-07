import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/responsive/responsive_extension.dart';

class PropertyFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool readOnly;
  final bool isDatePicker;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const PropertyFormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.readOnly = false,
    this.isDatePicker = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:  [
        if (label.isNotEmpty) ...[
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.2,
          ),

        ),

          SizedBox(height: 6.0.h),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly || isDatePicker,
            onTap: onTap,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF95A5A6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
              ),
              suffixIcon: isDatePicker
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF2C3E50),
                        size: 18,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
