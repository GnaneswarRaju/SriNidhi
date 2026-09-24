import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_store/app/router.dart';
import 'package:hardware_store/core/config/app_config.dart';
import 'package:hardware_store/core/errors/app_exception.dart';
import 'package:hardware_store/core/logging/app_logger.dart';

void main() {
  String jwt(String role) =>
      'header.${base64Url.encode(utf8.encode(jsonEncode({'role': role})))}.signature';
  test('configuration accepts public keys, rejects privileged keys and insecure hosts', () {
    expect(const AppConfig().ready, isFalse);
    expect(
      AppConfig(
        supabaseUrl: 'https://store.supabase.co',
        supabaseKey: jwt('anon'),
      ).ready,
      isTrue,
    );
    expect(
      AppConfig(
        supabaseUrl: 'https://store.supabase.co',
        supabaseKey: jwt('service_role'),
      ).ready,
      isFalse,
    );
    expect(
      const AppConfig(
        supabaseUrl: 'http://store.example.com',
        supabaseKey: 'sb_publishable_example_only',
      ).ready,
      isFalse,
    );
    expect(
      const AppConfig(
        supabaseUrl: 'http://localhost:54321',
        supabaseKey: 'sb_publishable_example_only',
      ).ready,
      isTrue,
    );
    expect(
      const AppConfig(
        supabaseUrl: 'https://store.supabase.co',
        supabaseKey: 'sb_secret_example_only',
      ).ready,
      isFalse,
    );
  });
  test('protected deep links wait for auth and redirect signed out users', () {
    expect(
      routeRedirect(
        configured: true,
        loading: true,
        signedIn: false,
        location: '/settings',
      ),
      '/loading',
    );
    expect(
      routeRedirect(
        configured: true,
        loading: false,
        signedIn: false,
        location: '/workspace',
      ),
      '/sign-in',
    );
    expect(
      routeRedirect(
        configured: false,
        loading: false,
        signedIn: true,
        location: '/',
      ),
      '/setup',
    );
    expect(
      routeRedirect(
        configured: true,
        loading: false,
        signedIn: true,
        location: '/sign-in',
      ),
      '/',
    );
    expect(
      routeRedirect(
        configured: true,
        loading: false,
        signedIn: true,
        location: '/settings',
      ),
      isNull,
    );
  });
  test('logs reject arbitrary correlation payloads', () {
    final messages = <String>[];
    AppLogger(sink: messages.add).error(
      LogModule.auth,
      LogOperation.signIn,
      ErrorCode.authentication,
      correlationId: 'password=secret-token',
    );
    final log = jsonDecode(messages.single) as Map;
    expect(log['code'], 'authentication');
    expect(log.containsKey('correlation_id'), isFalse);
    expect(messages.single, isNot(contains('secret-token')));
  });
}
