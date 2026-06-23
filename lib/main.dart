import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/app.dart';
import 'src/utils/http_overrides_io.dart'
    if (dart.library.html) 'src/utils/http_overrides_web.dart' as platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Overwrite HTTP only in Debug Mode for lower version android phones
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
