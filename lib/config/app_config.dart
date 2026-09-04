enum Environment {
  development,
  production,
}

class AppConfig {
  final Environment environment;

  const AppConfig({
    required this.environment,
  });

  bool get isDevelopment => environment == Environment.development;

  bool get isProduction => environment == Environment.production;

  String get name => switch (environment) {
    Environment.development => 'DEV',
    Environment.production => 'PROD',
  };

  String get appLogo => isDevelopment ? 'assets/images/app_logo_dev.png' : 'assets/images/app_logo.png';

  String get appTitle => isDevelopment ? 'Estoque PRO - DEV' : 'Estoque PRO';
}
