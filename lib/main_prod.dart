import 'src/utils/http_overrides_io.dart'
    if (dart.library.html) 'src/utils/http_overrides_web.dart' as platform;

import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/flavors.dart';
import 'src/app.dart';

/// Production entry point.
/// Run with: flutter run -t lib/main_prod.dart
/// Build web: flutter build web --release -t lib/main_prod.dart --base-href /sgt_school/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ① Set flavor BEFORE anything else reads the base URL
  FlavorConfig.load(Flavor.prod);

  // Apply debug HTTP overrides (only on non-web platforms)
  platform.applyHttpOverrides();

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await AppConfig.init();

  runApp(
    const LocalizationWrapper(
      child: StateWrapper(
        child: App(),
      ),
    ),
  );
}
