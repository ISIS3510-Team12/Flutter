import './service_locator.dart';

class DevConfig {
  const DevConfig._();

  static bool get enabled => useDevConfig;

  static String get host => Uri.parse(apiUrl).host;

  static const int authPort = 9099;

  static const String apiUrl = 'http://10.0.2.2:8000';
}
