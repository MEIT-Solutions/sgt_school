import 'package:sgt_school/src/imports/core_imports.dart';

/// Legacy wrapper — session-based navigation is now handled by
/// GoRouter's `redirect` + `refreshListenable` in [buildAppRouter].
///
/// This widget is kept as a pass-through to avoid breaking barrel exports.
class SessionListenerWrapper extends StatelessWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
