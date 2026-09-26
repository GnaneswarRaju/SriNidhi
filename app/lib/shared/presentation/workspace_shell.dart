import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/workspace/presentation/workspace_controller.dart';
import '../../l10n/generated/app_localizations.dart';

class WorkspaceShell extends ConsumerWidget {
  const WorkspaceShell({required this.path, required this.child, super.key});
  final String path;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final workspace = ref.watch(workspaceControllerProvider);
    final auth = ref.watch(authControllerProvider);
    const paths = ['/', '/workspace', '/settings'];
    final index = paths.indexOf(path).clamp(0, 2);
    final labels = [l.overview, l.workspace, l.settings];
    const icons = [
      Icons.dashboard_outlined,
      Icons.storefront_outlined,
      Icons.settings_outlined,
    ];
    void navigate(int i) => context.go(paths[i]);
    final body = workspace.when(
      skipLoadingOnRefresh: false,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _AccessMessage(
        message: l.workspaceError,
        onRetry: () => ref.invalidate(workspaceControllerProvider),
      ),
      data: (value) => value.memberships.isEmpty
          ? _AccessMessage(
              title: l.accessTitle,
              message: l.accessBody,
              onRetry: () => ref.invalidate(workspaceControllerProvider),
            )
          : child,
    );
    ref.listen(authControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.signOutError)));
      }
    });
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final expanded = constraints.maxWidth >= 1024;
        return Scaffold(
          appBar: AppBar(
            title: Text(l.appTitle),
            actions: [
              TextButton.icon(
                onPressed: auth.isLoading
                    ? null
                    : () => ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout, size: 20),
                label: Text(l.signOut),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (!compact)
                  NavigationRail(
                    extended: expanded,
                    minExtendedWidth: 240,
                    selectedIndex: index,
                    onDestinationSelected: navigate,
                    labelType: expanded
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    destinations: [
                      for (var i = 0; i < 3; i++)
                        NavigationRailDestination(
                          icon: Icon(icons[i]),
                          label: Text(labels[i]),
                        ),
                    ],
                  ),
                Expanded(child: body),
              ],
            ),
          ),
          bottomNavigationBar: compact
              ? NavigationBar(
                  selectedIndex: index,
                  onDestinationSelected: navigate,
                  destinations: [
                    for (var i = 0; i < 3; i++)
                      NavigationDestination(
                        icon: Icon(icons[i]),
                        label: labels[i],
                      ),
                  ],
                )
              : null,
        );
      },
    );
  }
}

class _AccessMessage extends StatelessWidget {
  const _AccessMessage({
    this.title,
    required this.message,
    required this.onRetry,
  });
  final String? title;
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 40),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
            ],
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    ),
  );
}
