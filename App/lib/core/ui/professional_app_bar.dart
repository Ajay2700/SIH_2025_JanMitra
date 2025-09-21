import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jan_mitra/core/theme/app_theme.dart';

class ProfessionalAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;

  const ProfessionalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackPressed,
    this.showBackButton = true,
    this.backgroundColor,
    this.foregroundColor,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ?? Colors.white;

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: effectiveForegroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      leading: _buildLeading(context, effectiveForegroundColor),
      actions: actions,
      iconTheme: IconThemeData(color: effectiveForegroundColor),
      actionsIconTheme: IconThemeData(color: effectiveForegroundColor),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios, color: foregroundColor),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Specialized AppBars for different contexts
class HomeAppBar extends ProfessionalAppBar {
  const HomeAppBar({
    super.key,
    required super.title,
    super.actions,
    super.onBackPressed,
    super.showBackButton = false,
    super.backgroundColor = AppTheme.primaryColor,
    super.centerTitle = true,
  });
}

class FormAppBar extends ProfessionalAppBar {
  const FormAppBar({
    super.key,
    required super.title,
    super.onBackPressed,
    super.backgroundColor = Colors.white,
    super.foregroundColor = Colors.black87,
    super.elevation = 1,
  });
}

class ProfileAppBar extends ProfessionalAppBar {
  const ProfileAppBar({
    super.key,
    required super.title,
    super.actions,
    super.onBackPressed,
    super.backgroundColor = AppTheme.primaryColor,
    super.centerTitle = true,
  });
}

class IssueFeedAppBar extends ProfessionalAppBar {
  const IssueFeedAppBar({
    super.key,
    required super.title,
    super.actions,
    super.onBackPressed,
    super.showBackButton = true,
    super.backgroundColor = AppTheme.primaryColor,
    super.centerTitle = true,
  });
}
