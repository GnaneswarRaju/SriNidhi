import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/generated/app_localizations.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context).loading),
        ],
      ),
    ),
  );
}

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.storefront_outlined, size: 40),
                      const SizedBox(height: 24),
                      Text(
                        l.appTitle,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l.setupTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ref.watch(configProvider).startupFailed
                            ? l.startupError
                            : l.setupBody,
                      ),
                      const SizedBox(height: 24),
                      SelectableText(l.setupInstructions),
                      const SizedBox(height: 24),
                      Text(
                        l.setupPrivacy,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.pageNotFound),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/'),
              child: Text(l.returnHome),
            ),
          ],
        ),
      ),
    );
  }
}
