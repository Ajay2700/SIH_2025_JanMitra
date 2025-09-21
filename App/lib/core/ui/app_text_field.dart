import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jan_mitra/core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final Widget? prefix;
  final IconData? suffixIcon;
  final Widget? suffix;
  final VoidCallback? onSuffixIconTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;
  final bool filled;
  final Color? fillColor;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.suffix,
    this.onSuffixIconTap,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
    this.contentPadding,
    this.textCapitalization = TextCapitalization.none,
    this.filled = true,
    this.fillColor,
    this.style,
    this.textAlign = TextAlign.start,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? suffixWidget;
    if (suffix != null) {
      suffixWidget = suffix;
    } else if (suffixIcon != null) {
      suffixWidget = InkWell(
        onTap: onSuffixIconTap,
        borderRadius: BorderRadius.circular(50),
        child: Icon(suffixIcon, size: 20),
      );
    }

    Widget? prefixWidget;
    if (prefix != null) {
      prefixWidget = prefix;
    } else if (prefixIcon != null) {
      prefixWidget = Icon(prefixIcon, size: 20);
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      autofocus: autofocus,
      readOnly: readOnly,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      style: style ?? theme.textTheme.bodyLarge,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        filled: filled,
        fillColor:
            fillColor ??
            (theme.brightness == Brightness.light
                ? Colors.white
                : theme.inputDecorationTheme.fillColor),
        prefixIcon: prefixWidget != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: prefixWidget,
              )
            : null,
        prefixIconConstraints: prefixIconConstraints,
        suffixIcon: suffixWidget != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: suffixWidget,
              )
            : null,
        suffixIconConstraints: suffixIconConstraints,
        contentPadding: contentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.brightness == Brightness.light
                ? AppTheme.grey300
                : AppTheme.grey700,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.brightness == Brightness.light
                ? AppTheme.grey300
                : AppTheme.grey700,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
      ),
    );
  }
}
