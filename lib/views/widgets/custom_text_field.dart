import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

class CustomTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final IconData? prefixIcon;
  final Color? iconColor; // Added to support custom icon color
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
  final int? minLines;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.prefixIcon,
    this.iconColor, // Added to constructor
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
    this.minLines,
    this.maxLines,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
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
            minLines: minLines,
            maxLines: maxLines ?? 1,
            inputFormatters: inputFormatters,
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
                      color: iconColor ?? const Color(0xFF1A6B47), // Use provided iconColor or default to dark green
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

  double _calculateHeight(
    BuildContext context,
    EdgeInsetsGeometry contentPadding,
    double fontSize,
    int? minLines,
    int? maxLines,
    String? errorText,
    double scaleFactor,
  ) {
    final double lineHeight = fontSize * 1.5;
    final int effectiveMinLines = minLines ?? 1;
    double baseHeight = contentPadding.vertical + (lineHeight * effectiveMinLines);
    if (errorText != null && errorText.isNotEmpty) {
      baseHeight += (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12 * scaleFactor) + 4;
    }
    return baseHeight.clamp(48.0, 300.0);
  }
}