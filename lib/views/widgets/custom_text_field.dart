import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final IconData prefixIcon;
  final Function(String)? onChanged;
  final double scaleFactor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    required this.prefixIcon,
    this.onChanged,
    this.scaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14 * scaleFactor,
            color: Colors.grey.shade800,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14 * scaleFactor,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.grey.shade600,
              size: 20 * scaleFactor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
            contentPadding: EdgeInsets.symmetric(
              vertical: 12 * scaleFactor,
              horizontal: 14 * scaleFactor,
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4 * scaleFactor, left: 10 * scaleFactor),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 12 * scaleFactor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}