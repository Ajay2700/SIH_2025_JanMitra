import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onRefreshTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final bool showNotificationBadge;
  final int notificationCount;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onRefreshTap,
    this.onProfileTap,
    this.onNotificationTap,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.showBackButton = false,
    this.onBackTap,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? (isDark ? Colors.white : Colors.white),
        ),
      ),
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor:
          foregroundColor ?? (isDark ? Colors.white : Colors.white),
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: actions ?? _buildDefaultActions(context),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor ?? theme.colorScheme.primary,
              (backgroundColor ?? theme.colorScheme.primary).withOpacity(0.8),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, color: foregroundColor ?? Colors.white),
      onPressed: onBackTap ?? () => Get.back(),
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    final actions = <Widget>[];

    // Refresh button
    if (onRefreshTap != null) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: foregroundColor ?? Colors.white,
          ),
          onPressed: onRefreshTap,
          tooltip: 'Refresh',
        ),
      );
    }

    // Notification button
    if (onNotificationTap != null) {
      actions.add(
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: foregroundColor ?? Colors.white,
              ),
              onPressed: onNotificationTap,
              tooltip: 'Notifications',
            ),
            if (showNotificationBadge && notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 99
                        ? '99+'
                        : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Profile button
    if (onProfileTap != null) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.person_outline_rounded,
            color: foregroundColor ?? Colors.white,
          ),
          onPressed: onProfileTap,
          tooltip: 'Profile',
        ),
      );
    }

    return actions;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onRefreshTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final bool showNotificationBadge;
  final int notificationCount;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? leading;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onRefreshTap,
    this.onProfileTap,
    this.onNotificationTap,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.showBackButton = false,
    this.onBackTap,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.leading,
    this.expandedHeight = 200,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? (isDark ? Colors.white : Colors.white),
        ),
      ),
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor:
          foregroundColor ?? (isDark ? Colors.white : Colors.white),
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: actions ?? _buildDefaultActions(context),
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace ?? _buildDefaultFlexibleSpace(context),
      pinned: pinned,
      floating: floating,
    );
  }

  Widget? _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, color: foregroundColor ?? Colors.white),
      onPressed: onBackTap ?? () => Get.back(),
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    final actions = <Widget>[];

    if (onRefreshTap != null) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: foregroundColor ?? Colors.white,
          ),
          onPressed: onRefreshTap,
          tooltip: 'Refresh',
        ),
      );
    }

    if (onNotificationTap != null) {
      actions.add(
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: foregroundColor ?? Colors.white,
              ),
              onPressed: onNotificationTap,
              tooltip: 'Notifications',
            ),
            if (showNotificationBadge && notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 99
                        ? '99+'
                        : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (onProfileTap != null) {
      actions.add(
        IconButton(
          icon: Icon(
            Icons.person_outline_rounded,
            color: foregroundColor ?? Colors.white,
          ),
          onPressed: onProfileTap,
          tooltip: 'Profile',
        ),
      );
    }

    return actions;
  }

  Widget _buildDefaultFlexibleSpace(BuildContext context) {
    return FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor ?? Theme.of(context).colorScheme.primary,
              (backgroundColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.location_city_rounded,
                size: 60,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(height: 16),
              Text(
                'Jan Mitra',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Empowering Citizens, Improving Cities',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
