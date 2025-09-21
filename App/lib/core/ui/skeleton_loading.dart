import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8.0,
    this.baseColor,
    this.highlightColor,
    this.shape = BoxShape.rectangle,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBaseColor =
        baseColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final effectiveHighlightColor =
        highlightColor ?? (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return Shimmer.fromColors(
      baseColor: effectiveBaseColor,
      highlightColor: effectiveHighlightColor,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(borderRadius),
          shape: shape,
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final bool hasImage;
  final bool hasTitle;
  final bool hasSubtitle;
  final bool hasAction;
  final int lines;

  const SkeletonCard({
    super.key,
    this.height = 120,
    this.width,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 16),
    this.borderRadius = 16,
    this.hasImage = true,
    this.hasTitle = true,
    this.hasSubtitle = true,
    this.hasAction = false,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage) SkeletonLoading(width: 80, height: 80, borderRadius: 8),
          if (hasImage) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle) ...[
                  SkeletonLoading(width: double.infinity, height: 20),
                  const SizedBox(height: 8),
                ],
                if (hasSubtitle) ...[
                  SkeletonLoading(width: double.infinity * 0.7, height: 16),
                  const SizedBox(height: 12),
                ],
                ...List.generate(
                  lines,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: index < lines - 1 ? 8 : 0),
                    child: SkeletonLoading(
                      width: double.infinity * (1 - (index * 0.1)),
                      height: 12,
                    ),
                  ),
                ),
                if (hasAction) ...[
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SkeletonLoading(width: 80, height: 32, borderRadius: 16),
                    ],
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

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final IndexedWidgetBuilder? itemBuilder;
  final double itemHeight;
  final double itemSpacing;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.scrollable = true,
    this.padding = const EdgeInsets.all(16),
    this.itemBuilder,
    this.itemHeight = 120,
    this.itemSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final list = List.generate(
      itemCount,
      (index) => itemBuilder != null
          ? itemBuilder!(context, index)
          : SkeletonCard(
              height: itemHeight,
              margin: EdgeInsets.only(bottom: itemSpacing),
            ),
    );

    if (scrollable) {
      return ListView(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        children: list,
      );
    } else {
      return Padding(
        padding: padding,
        child: Column(children: list),
      );
    }
  }
}
