import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller; // Now optional
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final IconData prefixIcon;
  final Function(String)? onChanged;
  final double scaleFactor;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
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
        Container(
          height: 50 * scaleFactor,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 14 * scaleFactor,
                ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14 * scaleFactor,
                    fontWeight: FontWeight.w500,
                  ),
              prefixIcon: Icon(
                prefixIcon,
                size: 20 * scaleFactor,
                color: Theme.of(context).inputDecorationTheme.prefixIconColor,
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
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              contentPadding: EdgeInsets.symmetric(
                vertical: 12 * scaleFactor,
                horizontal: 14 * scaleFactor,
              ),
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4 * scaleFactor, left: 10 * scaleFactor),
            child: Text(
              errorText!,
              style: Theme.of(context).inputDecorationTheme.errorStyle!.copyWith(
                    fontSize: 12 * scaleFactor,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
      ],
    );
  }
}