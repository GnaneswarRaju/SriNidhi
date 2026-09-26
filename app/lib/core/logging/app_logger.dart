import 'dart:convert';
import 'dart:developer' as developer;

import '../errors/app_exception.dart';

enum LogModule { auth, workspace, storage, application, products }

enum LogOperation {
  signIn,
  signOut,
  loadMemberships,
  savePreference,
  bootstrap,
  frameworkError,
  loadProducts,
  saveProduct,
}

/// Closed fields prevent arbitrary SDK errors, passwords or invoice payloads
/// entering logs. Error messages are mapped to codes at repository boundaries.
class AppLogger {
  AppLogger({
    void Function(String)? sink,
    this.version = 'local',
    this.commit = 'local',
  }) : _sink = sink ?? ((message) => developer.log(message, name: 'store'));
  final void Function(String) _sink;
  final String version;
  final String commit;

  void error(
    LogModule module,
    LogOperation operation,
    ErrorCode code, {
    String? correlationId,
  }) {
    final safeId =
        correlationId != null &&
            RegExp(r'^[a-fA-F0-9-]{36}$').hasMatch(correlationId)
        ? correlationId
        : null;
    _sink(
      jsonEncode({
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'level': 'error',
        'module': module.name,
        'operation': operation.name,
        'code': code.name,
        'version': version,
        'commit': commit,
        'correlation_id': ?safeId,
      }),
    );
  }
}
