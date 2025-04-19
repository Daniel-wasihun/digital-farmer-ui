import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final IconData? prefixIcon;
  final Function(String)? onChanged;
  final double scaleFactor;
  final bool enabled;
  final double? fontSize;
  final double? labelFontSize;
  final double? iconSize;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final bool? filled;
  final Color? fillColor;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final Color? cursorColor;
  // New parameters for multiline support
  final int? minLines;
  final int? maxLines;

  const CustomTextField({
    super.key,
    this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.prefixIcon,
    this.onChanged,
    this.scaleFactor = 1.0,
    this.enabled = true,
    this.fontSize,
    this.labelFontSize,
    this.iconSize,
    this.contentPadding,
    this.borderRadius,
    this.filled,
    this.fillColor,
    this.textInputAction,
    this.onSubmitted,
    this.cursorColor,
    this.minLines, // Add minLines
    this.maxLines, // Add maxLines
  });

  @override
  Widget build(BuildContext context) {
    // Use provided values or default to scaled values if null
    final double effectiveFontSize = fontSize ?? (14 * scaleFactor);
    final double effectiveLabelFontSize = labelFontSize ?? (14 * scaleFactor);
    final double effectiveIconSize = iconSize ?? (20 * scaleFactor);
    final double effectiveBorderRadius = borderRadius ?? 10.0;
    final bool effectiveFilled = filled ?? true;
    final EdgeInsetsGeometry effectiveContentPadding = contentPadding ??
        EdgeInsets.symmetric(
          vertical: 12 * scaleFactor,
          horizontal: 14 * scaleFactor,
        );

    // Define standard border styles
    final OutlineInputBorder standardBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      borderSide: effectiveFilled
          ? (Theme.of(context).inputDecorationTheme.enabledBorder as OutlineInputBorder?)?.borderSide ?? BorderSide.none
          : (Theme.of(context).inputDecorationTheme.enabledBorder as OutlineInputBorder?)?.borderSide ?? const BorderSide(color: Colors.grey, width: 1.0),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      borderSide: (Theme.of(context).inputDecorationTheme.focusedBorder as OutlineInputBorder?)?.borderSide ?? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          // Adjust height dynamically based on minLines/maxLines
          height: _calculateHeight(
            context,
            effectiveContentPadding,
            effectiveFontSize,
            minLines,
            maxLines,
            errorText,
            scaleFactor,
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            enabled: enabled,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            minLines: minLines, // Pass minLines to TextField
            maxLines: maxLines ?? 1, // Pass maxLines, default to 1 for single-line
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: effectiveFontSize,
                ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: effectiveLabelFontSize,
                    fontWeight: FontWeight.w500,
                  ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: effectiveIconSize,
                      color: Theme.of(context).inputDecorationTheme.prefixIconColor,
                    )
                  : null,
              border: standardBorder,
              enabledBorder: standardBorder,
              focusedBorder: focusedBorder,
              errorBorder: standardBorder,
              focusedErrorBorder: focusedBorder,
              filled: effectiveFilled,
              fillColor: fillColor ?? Theme.of(context).inputDecorationTheme.fillColor,
              contentPadding: effectiveContentPadding,
              errorText: errorText,
              errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: (12 * scaleFactor).clamp(8.5, 11.0),
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            cursorColor: cursorColor ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // Helper to calculate dynamic height for the TextField
  double _calculateHeight(
    BuildContext context,
    EdgeInsetsGeometry contentPadding,
    double fontSize,
    int? minLines,
    int? maxLines,
    String? errorText,
    double scaleFactor,
  ) {
    // Base height per line (fontSize + line spacing)
    final double lineHeight = fontSize * 1.5; // Approximate line height
    // Minimum height based on minLines or 1 line
    final int effectiveMinLines = minLines ?? 1;
    // Calculate base height from content padding and lines
    double baseHeight = contentPadding.vertical + (lineHeight * effectiveMinLines);
    // Add space for error text if present
    if (errorText != null && errorText.isNotEmpty) {
      baseHeight += (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12 * scaleFactor) + 4;
    }
    // Clamp height to reasonable bounds
    return baseHeight.clamp(48.0, 300.0); // Minimum 48px, maximum 300px
  }
}