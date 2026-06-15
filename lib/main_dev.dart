import 'dart:io';

import 'src/imports/core_imports.dart';
import 'src/imports/packages_imports.dart';
import 'src/flavors.dart';
import 'src/app.dart';

/// Development entry point.
/// Run with: flutter run -t lib/main_dev.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ① Set flavor BEFORE anything else reads the base URL
  FlavorConfig.load(Flavor.dev);

  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: '.env');

  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
