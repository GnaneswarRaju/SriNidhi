import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/presentation/page_content.dart';
import 'workspace_controller.dart';

class WorkspaceScreen extends ConsumerWidget {
  const WorkspaceScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(workspaceControllerProvider).asData?.value;
    if (state == null) return const SizedBox.shrink();
    return PageContent(
      title: l.chooseBranch,
      subtitle: l.workspaceSubtitle,
      children: [
        if (state.saving) const LinearProgressIndicator(),
        for (final branch in state.memberships)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.businessName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    branch.branchName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(branch.branchCode),
                  const SizedBox(height: 16),
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
                    onPressed:
                        state.saving ||
                            branch.branchId == state.selected?.branchId
                        ? null
                        : () => ref
                              .read(workspaceControllerProvider.notifier)
                              .selectBranch(branch.branchId),
                    icon: Icon(
                      branch.branchId == state.selected?.branchId
                          ? Icons.check_circle
                          : Icons.arrow_forward,
                    ),
                    label: Text(
                      branch.branchId == state.selected?.branchId
                          ? l.selected
                          : l.selectBranch,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
