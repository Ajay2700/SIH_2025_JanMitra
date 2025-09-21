import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final AppLoadingType type;

  const AppLoading({
    super.key,
    this.message,
    this.size = 50.0,
    this.color,
    this.type = AppLoadingType.bounce,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loadingColor = color ?? theme.colorScheme.primary;

    Widget spinner;
    switch (type) {
      case AppLoadingType.bounce:
        spinner = SpinKitDoubleBounce(color: loadingColor, size: size!);
        break;
      case AppLoadingType.pulse:
        spinner = SpinKitPulse(color: loadingColor, size: size!);
        break;
      case AppLoadingType.threeBounce:
        spinner = SpinKitThreeBounce(color: loadingColor, size: size!);
        break;
      case AppLoadingType.fadingCircle:
        spinner = SpinKitFadingCircle(color: loadingColor, size: size!);
        break;
      case AppLoadingType.rotatingCircle:
        spinner = SpinKitRotatingCircle(color: loadingColor, size: size!);
        break;
      case AppLoadingType.cubeGrid:
        spinner = SpinKitCubeGrid(color: loadingColor, size: size!);
        break;
      case AppLoadingType.wave:
        spinner = SpinKitWave(color: loadingColor, size: size!);
        break;
      case AppLoadingType.foldingCube:
        spinner = SpinKitFoldingCube(color: loadingColor, size: size!);
        break;
      case AppLoadingType.ring:
        spinner = SpinKitRing(color: loadingColor, size: size!);
        break;
      case AppLoadingType.dualRing:
        spinner = SpinKitDualRing(color: loadingColor, size: size!);
        break;
      case AppLoadingType.chasingDots:
        spinner = SpinKitChasingDots(color: loadingColor, size: size!);
        break;
      case AppLoadingType.hourGlass:
        spinner = SpinKitHourGlass(color: loadingColor, size: size!);
        break;
      case AppLoadingType.ripple:
        spinner = SpinKitRipple(color: loadingColor, size: size!);
        break;
      case AppLoadingType.spinningCircle:
        spinner = SpinKitSpinningCircle(color: loadingColor, size: size!);
        break;
      case AppLoadingType.fadingGrid:
        spinner = SpinKitFadingGrid(color: loadingColor, size: size!);
        break;
      case AppLoadingType.squareCircle:
        spinner = SpinKitSquareCircle(color: loadingColor, size: size!);
        break;
      case AppLoadingType.dancingSquare:
        spinner = SpinKitDancingSquare(color: loadingColor, size: size!);
        break;
      case AppLoadingType.pouringHourGlass:
        spinner = SpinKitPouringHourGlass(color: loadingColor, size: size!);
        break;
      case AppLoadingType.pouringHourGlassRefined:
        spinner = SpinKitPouringHourGlassRefined(
          color: loadingColor,
          size: size!,
        );
        break;
      case AppLoadingType.professional:
        spinner = _buildProfessionalLoader(context, loadingColor, size!);
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        spinner,
        if (message != null) ...[
          const SizedBox(height: 24),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildProfessionalLoader(
    BuildContext context,
    Color color,
    double size,
  ) {
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 3),
            ),
          ),
          // Inner spinning ring
          SpinKitRing(color: color, size: size - 10, lineWidth: 3),
          // Center dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

enum AppLoadingType {
  bounce,
  pulse,
  threeBounce,
  fadingCircle,
  rotatingCircle,
  cubeGrid,
  wave,
  foldingCube,
  ring,
  dualRing,
  chasingDots,
  hourGlass,
  ripple,
  spinningCircle,
  fadingGrid,
  squareCircle,
  dancingSquare,
  pouringHourGlass,
  pouringHourGlassRefined,
  professional,
}

class AppLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? backgroundColor;
  final AppLoadingType loadingType;

  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.backgroundColor,
    this.loadingType = AppLoadingType.bounce,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppLoading(message: loadingMessage, type: loadingType),
              ),
            ),
          ),
      ],
    );
  }
}

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? color;

  const AppErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onRetry,
    this.retryText = 'Retry',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final errorColor = color ?? theme.colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 80,
              color: errorColor.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppEmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;
  final Color? color;

  const AppEmptyWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.onAction,
    this.actionText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final emptyColor = color ?? theme.colorScheme.primary.withOpacity(0.7);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon ?? Icons.inbox_outlined, size: 80, color: emptyColor),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: emptyColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor =
        widget.baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor =
        widget.highlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
