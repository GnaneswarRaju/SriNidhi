import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/presentation/page_content.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final config = ref.watch(configProvider);
    final user = ref.watch(sessionProvider).asData?.value;
    return PageContent(
      title: l.settings,
      subtitle: l.settingsSubtitle,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.account, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SelectableText(user?.email ?? ''),
                const Divider(height: 40),
                Text(
                  l.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(l.english),
                const SizedBox(height: 8),
                Text(l.translationNote),
                const Divider(height: 40),
                Text(l.version, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SelectableText(config.version),
                const SizedBox(height: 24),
                Text(l.commit, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SelectableText(config.gitSha),
              ],
            ),
          ),
        ),
        InfoCard(
          title: l.privacyTitle,
          body: l.privacyBody,
          icon: Icons.shield_outlined,
        ),
      ],
    );
  }
}
