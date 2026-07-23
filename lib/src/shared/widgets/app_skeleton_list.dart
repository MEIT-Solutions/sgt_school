import '../../imports/imports.dart';

/// A reusable skeleton loading list that wraps [SkeletonWrapper].
///
/// Provides a consistent shimmer loading experience across all list screens.
/// Use the [itemBuilder] for custom skeleton row layouts, or rely on the
/// default card skeleton.
///
/// ```dart
/// AppSkeletonList() // default 8-item card skeleton
/// AppSkeletonList(itemCount: 5, itemBuilder: (context) => MyCustomSkeleton())
/// ```
class AppSkeletonList extends StatelessWidget {
  /// Number of skeleton items to show.
  final int itemCount;

  /// Custom builder for each skeleton item. If null, uses the default card.
  final WidgetBuilder? itemBuilder;

  /// Spacing between items.
  final double spacing;

  /// Padding around the list.
  final EdgeInsetsGeometry padding;

  const AppSkeletonList({
    super.key,
    this.itemCount = 8,
    this.itemBuilder,
    this.spacing = 10,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;

    return SkeletonWrapper(
      isLoading: true,
      child: ListView.separated(
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (context, _) =>
            itemBuilder?.call(context) ??
            _DefaultSkeletonCard(cs: cs, textTheme: theme.textTheme),
      ),
    );
  }
}

/// Default skeleton card: icon box + title + subtitle row.
class _DefaultSkeletonCard extends StatelessWidget {
  final ColorScheme cs;
  final TextTheme textTheme;

  const _DefaultSkeletonCard({required this.cs, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.article, color: cs.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BoneMock.name,
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  BoneMock.subtitle,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
