import 'package:flutter/material.dart';

import '../../features/workspace/domain/branch_membership.dart';
import '../../l10n/generated/app_localizations.dart';

String roleLabel(AppLocalizations l, StoreRole role) => switch (role) {
  StoreRole.owner => l.ownerRole,
  StoreRole.admin => l.adminRole,
  StoreRole.manager => l.managerRole,
  StoreRole.cashier => l.cashierRole,
  StoreRole.stockManager => l.stockManagerRole,
  StoreRole.accountant => l.accountantRole,
};

class PageContent extends StatelessWidget {
  const PageContent({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });
  final String title;
  final String subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context).foundationLabel,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(subtitle),
            const SizedBox(height: 32),
            for (final child in children) ...[
              child,
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    ),
  );
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.body,
    required this.icon,
    this.highlight = false,
    super.key,
  });
  final String title;
  final String body;
  final IconData icon;
  final bool highlight;
  @override
  Widget build(BuildContext context) => Card(
    color: highlight ? Theme.of(context).colorScheme.primaryContainer : null,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(body),
        ],
      ),
    ),
  );
}
