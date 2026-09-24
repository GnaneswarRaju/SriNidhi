import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide ErrorCode;

import 'app/providers.dart';
import 'app/store_app.dart';
import 'core/config/app_config.dart';
import 'core/errors/app_exception.dart';
import 'core/logging/app_logger.dart';
import 'features/auth/data/secure_session_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var config = AppConfig.environment();
  final logger = AppLogger(version: config.version, commit: config.gitSha);
  FlutterError.onError = (_) => logger.error(
    LogModule.application,
    LogOperation.frameworkError,
    ErrorCode.unknown,
  );
  PlatformDispatcher.instance.onError = (_, _) {
    logger.error(
      LogModule.application,
      LogOperation.frameworkError,
      ErrorCode.unknown,
    );
    return true;
  };
  if (config.isConfigured) {
    try {
      await Supabase.initialize(
        url: config.supabaseUrl,
        publishableKey: config.supabaseKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: SecureSessionStorage(
            Uri.parse(config.supabaseUrl).host,
          ),
        ),
        debug: false,
      );
    } catch (_) {
      logger.error(
        LogModule.application,
        LogOperation.bootstrap,
        ErrorCode.network,
      );
      config = AppConfig(
        supabaseUrl: config.supabaseUrl,
        supabaseKey: config.supabaseKey,
        version: config.version,
        gitSha: config.gitSha,
        startupFailed: true,
      );
    }
  }
  runApp(
    ProviderScope(
      overrides: [configProvider.overrideWithValue(config)],
      child: const StoreApp(),
    ),
  );
}
