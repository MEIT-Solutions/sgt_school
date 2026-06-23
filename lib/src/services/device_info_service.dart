import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../utils/utils.dart';

/// A service to retrieve detailed information about the current device.
class DeviceInfoService {
  DeviceInfoService._();
  static final DeviceInfoService instance = DeviceInfoService._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Retrieve full device information as a Map.
  FutureEither<Map<String, dynamic>> getFullDeviceInfo() async {
    return runTask(() async {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return {
          'browserName': webInfo.browserName.name,
          'platform': webInfo.platform,
          'userAgent': webInfo.userAgent,
          'language': webInfo.language,
        };
      }

      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final androidInfo = await _deviceInfo.androidInfo;
          return {
            'model': androidInfo.model,
            'manufacturer': androidInfo.manufacturer,
            'version': androidInfo.version.release,
            'sdkInt': androidInfo.version.sdkInt,
            'id': androidInfo.id,
            'isPhysicalDevice': androidInfo.isPhysicalDevice,
          };
        case TargetPlatform.iOS:
          final iosInfo = await _deviceInfo.iosInfo;
          return {
            'name': iosInfo.name,
            'model': iosInfo.model,
            'systemName': iosInfo.systemName,
            'systemVersion': iosInfo.systemVersion,
            'identifierForVendor': iosInfo.identifierForVendor,
            'isPhysicalDevice': iosInfo.isPhysicalDevice,
          };
        case TargetPlatform.macOS:
          final macInfo = await _deviceInfo.macOsInfo;
          return {
            'computerName': macInfo.computerName,
            'hostName': macInfo.hostName,
            'model': macInfo.model,
            'osRelease': macInfo.osRelease,
          };
        case TargetPlatform.windows:
          final winInfo = await _deviceInfo.windowsInfo;
          return {
            'computerName': winInfo.computerName,
            'numberOfCores': winInfo.numberOfCores,
            'systemMemoryInMegabytes': winInfo.systemMemoryInMegabytes,
          };
        default:
          return {'platform': 'unknown'};
      }
    });
  }
}
