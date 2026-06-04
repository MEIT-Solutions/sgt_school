import 'dart:ui';
import '../../imports/imports.dart';

/// Shows a highly customizable bottom sheet with premium features like backdrop blur.
///
/// This helper accepts an optional [context] parameter from the caller's
/// widget tree. Uses `useRootNavigator: false` to avoid GoRouter conflicts.
/// Falls back to [rootContext] only for fire-and-forget sheets without a widget tree.
Future<T?> showAppSheet<T>({
  required Widget child,
  BuildContext? context,
  bool hasBlur = true,
  bool enableDrag = true,
  bool isScrollControlled = true,
  bool useSafeArea = true,
}) {
  final ctx = context ?? rootContext;
  if (ctx == null) return Future.value(null);

  return showModalBottomSheet<T>(
    context: ctx,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: ctx.theme.colorScheme.scrim.withValues(alpha: 0.2),
    elevation: 0,
    useSafeArea: useSafeArea,
    enableDrag: enableDrag,
    useRootNavigator: false,
    shape: const RoundedRectangleBorder(
      borderRadius: AppBorders.bottomSheet,
    ),
    builder: (context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: hasBlur ? 3 : 0,
          sigmaY: hasBlur ? 3 : 0,
        ),
        child: SizedBox(
          child: child,
        ),
      ),
    ),
  );
}
