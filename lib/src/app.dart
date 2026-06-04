import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    //final settings = context.watch<SettingsProvider>();
    final session = context.watch<SessionProvider>();

    // Create router lazily once session provider is available.
    // This ensures refreshListenable is wired correctly.
    _router ??= buildAppRouter(session);

    return MaterialApp.router(
      title: 'SGT School',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#645bdc'),
      darkTheme: buildDarkTheme(primaryColorHex: '#645bdc'),
      themeMode: ThemeMode.light,
      routerConfig: _router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        return SkeletonWrapper(child: child!);
      },
    );
  }
}
