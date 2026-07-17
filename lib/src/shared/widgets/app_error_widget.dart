import '../../imports/imports.dart';

/// Displays an error state with an animated icon, title, optional body, and retry button.
///
/// Usage:
/// ```dart
/// AppErrorWidget(
///   title: 'Something went wrong',
///   message: error.toString(),
///   onRetry: () => ref.invalidate(myProvider),
/// )
/// ```
class AppErrorWidget extends StatefulWidget {
  const AppErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();

    // ── Entrance animation ──
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // ── Pulse animation for the icon ──
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _iconScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Center(
      child: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated icon with gradient circle ──
                ScaleTransition(
                  scale: _iconScale,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.error.withValues(alpha: 0.12),
                          cs.errorContainer.withValues(alpha: 0.20),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.error.withValues(alpha: 0.1),
                        ),
                        child: Icon(widget.icon, size: 32, color: cs.error),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ──
                Text(
                  widget.title,
                  style: tt.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                // ── Message ──
                if (widget.message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.message!,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // ── Retry button ──
                if (widget.onRetry != null) ...[
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Try Again',
                    onPressed: widget.onRetry,
                    prefixIcon: Icon(Icons.refresh_rounded, size: 18),
                    variant: ButtonVariant.outline,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
