import 'package:flutter/material.dart';
import 'package:jan_mitra/core/theme/app_theme.dart';
import 'package:jan_mitra/core/ui/app_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double? iconSize;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.buttonText,
    this.onButtonPressed,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveIconSize = iconSize ?? 80.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: effectiveIconSize,
              color: effectiveIconColor.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.brightness == Brightness.light
                    ? AppTheme.grey800
                    : AppTheme.grey200,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.brightness == Brightness.light
                    ? AppTheme.grey600
                    : AppTheme.grey400,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: buttonText!,
                onPressed: onButtonPressed!,
                type: AppButtonType.primary,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoIssuesEmptyState extends StatelessWidget {
  final VoidCallback? onCreatePressed;

  const NoIssuesEmptyState({
    super.key,
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.report_problem_outlined,
      title: 'No Issues Found',
      message: 'You haven\'t reported any issues yet. Tap the button below to report a new issue.',
      buttonText: 'Report New Issue',
      onButtonPressed: onCreatePressed,
    );
  }
}

class NoResultsEmptyState extends StatelessWidget {
  final VoidCallback? onResetFilters;

  const NoResultsEmptyState({
    super.key,
    this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'We couldn\'t find any issues matching your search criteria. Try adjusting your filters.',
      buttonText: onResetFilters != null ? 'Reset Filters' : null,
      onButtonPressed: onResetFilters,
    );
  }
}

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something Went Wrong',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: title,
      message: message,
      buttonText: onRetry != null ? 'Try Again' : null,
      onButtonPressed: onRetry,
      iconColor: Theme.of(context).colorScheme.error,
    );
  }
}
