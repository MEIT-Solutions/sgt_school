import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/flavors.dart';
import 'src/app.dart';
import 'src/utils/http_overrides_io.dart'
    if (dart.library.html) 'src/utils/http_overrides_web.dart' as platform;

/// Development entry point.
/// Run with: flutter run -t lib/main_dev.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ① Set flavor BEFORE anything else reads the base URL
  FlavorConfig.load(Flavor.dev);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Apply debug HTTP overrides (only on non-web platforms)
  if (kDebugMode) {
    platform.applyHttpOverrides();
  }

  await AppConfig.init();

  runApp(
    const LocalizationWrapper(
      child: StateWrapper(
        child: App(),
      ),
    ),
  );
}
