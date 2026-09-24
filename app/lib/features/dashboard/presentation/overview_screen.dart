import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/presentation/page_content.dart';
import '../../workspace/presentation/workspace_controller.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final branch = ref
        .watch(workspaceControllerProvider)
        .asData
        ?.value
        .selected;
    if (branch == null) return const SizedBox.shrink();
    return PageContent(
      title: l.overviewTitle,
      subtitle: l.overviewSubtitle,
      children: [
        InfoCard(
          title: l.workspaceReady,
          body: l.workspaceReadyBody,
          icon: Icons.check_circle_outline,
          highlight: true,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.business, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  branch.businessName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Text(l.branch, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  '${branch.branchName} · ${branch.branchCode}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                Text(l.role, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final role in branch.roles)
                      Chip(label: Text(roleLabel(l, role))),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => context.go('/workspace'),
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(l.changeBranch),
                ),
              ],
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              InfoCard(
                title: l.localStorage,
                body: l.localStorageReady,
                icon: Icons.storage_outlined,
              ),
              InfoCard(
                title: l.offlineTitle,
                body: l.offlineBody,
                icon: Icons.cloud_off_outlined,
              ),
            ];
            return constraints.maxWidth >= 700
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 24),
                      Expanded(child: cards[1]),
                    ],
                  )
                : Column(
                    children: [cards[0], const SizedBox(height: 24), cards[1]],
                  );
          },
        ),
        InfoCard(
          title: l.nextTitle,
          body: l.nextBody,
          icon: Icons.inventory_2_outlined,
        ),
      ],
    );
  }
}
