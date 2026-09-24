import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/sign_in_screen.dart';
import '../features/dashboard/presentation/overview_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/workspace/presentation/workspace_screen.dart';
import '../shared/presentation/foundation_screens.dart';
import '../shared/presentation/workspace_shell.dart';
import 'providers.dart';

String? routeRedirect({
  required bool configured,
  required bool loading,
  required bool signedIn,
  required String location,
}) {
  if (!configured) return location == '/setup' ? null : '/setup';
  if (loading) return location == '/loading' ? null : '/loading';
  if (!signedIn) return location == '/sign-in' ? null : '/sign-in';
  if (const ['/sign-in', '/setup', '/loading'].contains(location)) return '/';
  return null;
}

class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(sessionProvider, (_, _) => refresh.refresh());
  final router = GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      return routeRedirect(
        configured: ref.read(configProvider).ready,
        loading: session.isLoading,
        signedIn: session.asData?.value != null,
        location: state.uri.path,
      );
    },
    routes: [
      GoRoute(path: '/setup', builder: (_, _) => const SetupScreen()),
      GoRoute(path: '/loading', builder: (_, _) => const LoadingScreen()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      ShellRoute(
        builder: (_, state, child) =>
            WorkspaceShell(path: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const OverviewScreen()),
          GoRoute(
            path: '/workspace',
            builder: (_, _) => const WorkspaceScreen(),
          ),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
    ],
    errorBuilder: (_, _) => const NotFoundScreen(),
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
