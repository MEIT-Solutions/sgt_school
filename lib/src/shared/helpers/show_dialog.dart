import 'dart:ui';
import '../../imports/imports.dart';

/// Shows a premium custom dialog with optional backdrop blur.
///
/// **GoRouter safety**: This helper accepts a [context] parameter from the
/// caller's widget tree. The dialog is pushed onto the **nearest** navigator
/// (typically the ShellRoute navigator), not GoRouter's root navigator.
/// This prevents the "popped the last page off of the stack" assertion
/// that occurs when a dialog route is popped from GoRouter's root navigator.
///
/// Inside the dialog's [child], always dismiss via:
/// ```dart
/// popDialog(context, result); // preferred — safe helper
/// ```
/// or if you must use Navigator directly:
/// ```dart
/// Navigator.of(context).pop(result);
/// ```
/// where `context` is from a [Builder] widget wrapping your dialog content.
///
/// **NEVER** use `Navigator.of(context).pop()` with a context from outside
/// the dialog (e.g. the screen's context) — this pops the GoRouter route
/// instead of the dialog overlay.
Future<T?> showAppDialog<T>({
  required Widget child,
  BuildContext? context,
  bool hasBlur = true,
  double blurSigma = 5.0,
  Color barrierColor = Colors.black26,
  bool dismissible = true,
  Duration duration = const Duration(milliseconds: 300),
}) {
  // Prefer the caller's context; fall back to rootContext only for
  // fire-and-forget dialogs triggered from services without a widget tree.
  final ctx = context ?? rootContext;
  if (ctx == null) return Future.value(null);

  return showGeneralDialog<T>(
    context: ctx,
    barrierColor: barrierColor,
    barrierDismissible: dismissible,
    barrierLabel: 'AppDialog',
    transitionDuration: duration,
    // Use useRootNavigator: false so the dialog is pushed onto the nearest
    // navigator (ShellRoute) instead of GoRouter's root navigator.
    // This ensures Navigator.of(dialogContext).pop() only pops the dialog
    // overlay — not the GoRouter route underneath.
    useRootNavigator: false,
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = Curves.easeInOut.transform(animation.value);
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: hasBlur ? (blurSigma * animation.value) : 0,
          sigmaY: hasBlur ? (blurSigma * animation.value) : 0,
        ),
        child: Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * curve),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Safely pops the current dialog without interfering with GoRouter.
///
/// Use this inside dialog content instead of raw `Navigator.of(context).pop()`.
/// The [context] **must** be from inside the dialog widget tree — typically
/// from a [Builder] wrapper or the dialog's own build method.
///
/// ```dart
/// FilledButton(
///   onPressed: () => popDialog(context, true),
///   child: Text('Confirm'),
/// )
/// ```
void popDialog<T>(BuildContext context, [T? result]) {
  Navigator.of(context).pop(result);
}

/// Alias for [showAppDialog] to maintain compatibility with custom references.
Future<T?> showCustomDialogue<T>({
  required Widget child,
  BuildContext? context,
  bool hasBlur = true,
}) =>
    showAppDialog<T>(child: child, context: context, hasBlur: hasBlur);
