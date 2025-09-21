import 'package:flutter/material.dart';

enum AppButtonType { primary, secondary, text }

enum AppButtonSize { small, medium, large }

// Alias for backward compatibility
typedef ButtonVariant = AppButtonType;

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isFullWidth = false,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Determine padding based on size
    EdgeInsets padding;
    double fontSize;
    double iconSize;
    double height;

    switch (size) {
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        fontSize = 13;
        iconSize = 16;
        height = 36;
        break;
      case AppButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        fontSize = 16;
        iconSize = 20;
        height = 54;
        break;
      case AppButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        fontSize = 14;
        iconSize = 18;
        height = 46;
        break;
    }

    // Create button content
    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Container(
            width: iconSize,
            height: iconSize,
            margin: const EdgeInsets.only(right: 10),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.primary
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        else if (leadingIcon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(leadingIcon, size: iconSize),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        if (trailingIcon != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(trailingIcon, size: iconSize),
          ),
      ],
    );

    // Apply button style based on type
    switch (type) {
      case AppButtonType.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: height,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: buttonContent,
          ),
        );
      case AppButtonType.text:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: height,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: buttonContent,
          ),
        );
      case AppButtonType.primary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: buttonContent,
          ),
        );
    }
  }
}
