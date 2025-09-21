import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableFeedback;
  final double? width;
  final double? height;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
    this.enableFeedback = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget card = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        boxShadow: boxShadow ?? _getDefaultShadow(context, isDark),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          enableFeedback: enableFeedback,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: card,
        ),
      );
    }

    return card;
  }

  List<BoxShadow> _getDefaultShadow(BuildContext context, bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    }
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? iconSize;
  final bool isLoading;
  final Widget? trailing;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.iconSize = 32,
    this.isLoading = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(isDark ? 0.3 : 0.1),
          spreadRadius: 2,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          iconColor ?? theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    size: iconSize,
                    color: iconColor ?? theme.colorScheme.primary,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (trailing != null) ...[const SizedBox(height: 12), trailing!],
        ],
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = color ?? theme.colorScheme.primary;

    return AppCard(
      onTap: onTap,
      backgroundColor: cardColor.withOpacity(0.1),
      border: Border.all(color: cardColor.withOpacity(0.2), width: 1),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cardColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? action;

  const InfoCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color,
    this.onTap,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = color ?? theme.colorScheme.primary;

    return AppCard(
      onTap: onTap,
      backgroundColor: cardColor.withOpacity(0.05),
      border: Border.all(color: cardColor.withOpacity(0.2), width: 1),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(icon, color: cardColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}
