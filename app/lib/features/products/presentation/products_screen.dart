import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/presentation/page_content.dart';
import '../../workspace/domain/branch_membership.dart';
import '../../workspace/presentation/workspace_controller.dart';
import '../domain/product.dart';
import 'product_form.dart';
import 'product_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branch = ref
        .watch(workspaceControllerProvider)
        .asData
        ?.value
        .selected;
    if (branch == null) return const SizedBox.shrink();
    return _Catalogue(key: ValueKey(branch.branchId), branch: branch);
  }
}

class _Catalogue extends ConsumerStatefulWidget {
  const _Catalogue({required this.branch, super.key});
  final BranchMembership branch;
  @override
  ConsumerState<_Catalogue> createState() => _CatalogueState();
}

class _CatalogueState extends ConsumerState<_Catalogue> {
  final _search = TextEditingController();
  final List<Product?> _cursors = [null];
  String _query = '';
  bool _inactive = false;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reset() => _cursors
    ..clear()
    ..add(null);
  CatalogueQuery get query => (
    branchId: widget.branch.branchId,
    search: _query,
    inactive: _inactive,
    afterName: _cursors.last?.nameKey,
    afterId: _cursors.last?.id,
  );

  Future<void> _open([Product? product]) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProductForm(branch: widget.branch, product: product),
    );
    if (mounted) {
      setState(_reset);
      ref.invalidate(productPageProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final page = ref.watch(productPageProvider(query));
    final writable = canManageProducts(widget.branch);
    void search() => setState(() {
      _query = _search.text.trim();
      _reset();
    });
    return PageContent(
      title: l.productsTitle,
      subtitle: l.productsSubtitle,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            Text('${widget.branch.businessName} · ${widget.branch.branchName}'),
            if (writable)
              FilledButton.icon(
                onPressed: () => _open(),
                icon: const Icon(Icons.add),
                label: Text(l.addProduct),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _search,
              maxLength: 80,
              onSubmitted: (_) => search(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: l.searchProducts,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.tonal(onPressed: search, child: Text(l.search)),
                TextButton.icon(
                  onPressed: () {
                    setState(_reset);
                    ref.invalidate(productPageProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l.refreshProducts),
                ),
              ],
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(l.includeInactive),
              value: _inactive,
              onChanged: (value) => setState(() {
                _inactive = value!;
                _reset();
              }),
            ),
          ],
        ),
        page.when(
          skipLoadingOnRefresh: false,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.productsError),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(productPageProvider(query)),
                child: Text(l.retry),
              ),
            ],
          ),
          data: (value) {
            if (value.items.isEmpty) {
              return InfoCard(
                title: _query.isEmpty && _cursors.length == 1
                    ? l.emptyProducts
                    : l.noProductsFound,
                body: _query.isEmpty && _cursors.length == 1
                    ? (writable ? l.emptyProductsBody : l.emptyReadOnlyBody)
                    : l.noProductsFoundBody,
                icon: Icons.inventory_2_outlined,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final product in value.items)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 24,
                        runSpacing: 16,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.text('name'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${product.text('sku')} · ${product.text('base_unit')}',
                              ),
                              if (product.text('category').isNotEmpty)
                                Text(product.text('category')),
                              if (!product.active)
                                Text(
                                  l.inactiveProduct,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${product.text('sale_price')}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              TextButton.icon(
                                onPressed: () => _open(product),
                                icon: Icon(
                                  writable
                                      ? Icons.edit_outlined
                                      : Icons.visibility_outlined,
                                ),
                                label: Text(writable ? l.edit : l.viewDetails),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            OutlinedButton(
              onPressed: _cursors.length > 1 && !page.isLoading
                  ? () => setState(() => _cursors.removeLast())
                  : null,
              child: Text(l.previousPage),
            ),
            OutlinedButton(
              onPressed: page.asData?.value.hasMore == true && !page.isLoading
                  ? () => setState(
                      () => _cursors.add(page.asData!.value.items.last),
                    )
                  : null,
              child: Text(l.nextPage),
            ),
          ],
        ),
      ],
    );
  }
}
