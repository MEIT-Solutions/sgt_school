import 'dart:io';
import '../imports/imports.dart';

class InternetConnectionService {
  InternetConnectionService();

  final InternetConnection internetConnection = InternetConnection();

  Future<bool> hasConnection() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return true;
    }
    return await internetConnection.hasInternetAccess;
  }
}
