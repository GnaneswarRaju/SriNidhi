import 'dart:convert';

class AppConfig {
  const AppConfig({
    this.supabaseUrl = '',
    this.supabaseKey = '',
    this.version = '0.2.0-dev.1',
    this.gitSha = 'local',
    this.startupFailed = false,
  });

  factory AppConfig.environment() => const AppConfig(
    supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
    supabaseKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    version: String.fromEnvironment('APP_VERSION', defaultValue: '0.2.0-dev.1'),
    gitSha: String.fromEnvironment('GIT_SHA', defaultValue: 'local'),
  );

  final String supabaseUrl;
  final String supabaseKey;
  final String version;
  final String gitSha;
  final bool startupFailed;

  bool get isConfigured {
    final uri = Uri.tryParse(supabaseUrl);
    if (uri == null ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return false;
    }
    if (uri.scheme != 'https' &&
        !(uri.scheme == 'http' &&
            const ['localhost', '127.0.0.1', '10.0.2.2'].contains(uri.host))) {
      return false;
    }
    if (supabaseKey.startsWith('sb_publishable_')) {
      return supabaseKey.length > 20;
    }
    try {
      final parts = supabaseKey.split('.');
      if (parts.length != 3) return false;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      return payload is Map && payload['role'] == 'anon';
    } on FormatException {
      return false;
    }
  }

  bool get ready => isConfigured && !startupFailed;
}
