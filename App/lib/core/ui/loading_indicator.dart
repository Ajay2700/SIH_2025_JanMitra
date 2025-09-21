import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jan_mitra/core/theme/app_theme.dart';

enum LoadingSize { small, medium, large }

class LoadingIndicator extends StatelessWidget {
  final LoadingSize size;
  final Color? color;
  final String? message;

  const LoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    double indicatorSize;
    double textSize;

    switch (size) {
      case LoadingSize.small:
        indicatorSize = 24;
        textSize = 12;
        break;
      case LoadingSize.large:
        indicatorSize = 48;
        textSize = 16;
        break;
      case LoadingSize.medium:
        indicatorSize = 36;
        textSize = 14;
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitDoubleBounce(color: indicatorColor, size: indicatorSize),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: textSize,
                color: theme.brightness == Brightness.light
                    ? AppTheme.grey700
                    : AppTheme.grey300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const FullScreenLoader({super.key, this.message, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          backgroundColor ??
          (Theme.of(context).brightness == Brightness.light
              ? Colors.white.withOpacity(0.7)
              : Colors.black.withOpacity(0.7)),
      child: LoadingIndicator(size: LoadingSize.large, message: message),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(child: FullScreenLoader(message: message)),
      ],
    );
  }
}
