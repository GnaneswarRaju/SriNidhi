import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../workspace/domain/branch_membership.dart';
import '../domain/product.dart';
import '../domain/product_validation.dart';
import 'product_providers.dart';

class ProductForm extends ConsumerStatefulWidget {
  const ProductForm({required this.branch, this.product, super.key});
  final BranchMembership branch;
  final Product? product;
  @override
  ConsumerState<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<ProductForm> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  late final String _id;
  late final String? _userId;
  late String _unit;
  late bool _active;
  bool _busy = false;
  ErrorCode? _error;
  bool get writable => canManageProducts(widget.branch);
  bool get locked => !writable || _busy || _error == ErrorCode.network;

  @override
  void initState() {
    super.initState();
    _userId = ref.read(sessionProvider).asData?.value?.id;
    _id = widget.product?.id ?? newProductId();
    _unit = widget.product?.text('base_unit') ?? 'PCS';
    _active = widget.product?.active ?? true;
    _fields = {
      for (final key in Product.fields.where(
        (k) => k != 'active' && k != 'base_unit',
      ))
        key: TextEditingController(
          text:
              widget.product?.text(key) ??
              (key == 'reorder_quantity' ? '0' : ''),
        ),
    };
  }

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !writable || !_form.currentState!.validate()) return;
    if (_userId == null ||
        ref.read(sessionProvider).asData?.value?.id != _userId) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(productRepositoryProvider)
          .save(
            branchId: widget.branch.branchId,
            id: _id,
            version: widget.product?.version,
            data: {
              for (final entry in _fields.entries)
                entry.key: entry.value.text.trim(),
              'base_unit': _unit,
              'active': _active,
            },
          );
      if (mounted && ref.read(sessionProvider).asData?.value?.id == _userId) {
        setState(() => _busy = false);
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted && ref.read(sessionProvider).asData?.value?.id == _userId) {
        setState(() {
          _busy = false;
          _error = error is AppException ? error.code : ErrorCode.network;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.listen(sessionProvider, (_, next) {
      if (next.asData?.value?.id != _userId && mounted) {
        Navigator.of(context).pop();
      }
    });
    final unitLabels = [
      l.unitPcs,
      l.unitBox,
      l.unitPack,
      l.unitBag,
      l.unitSet,
      l.unitRoll,
      l.unitKg,
      l.unitG,
      l.unitM,
      l.unitCm,
      l.unitFt,
      l.unitL,
      l.unitMl,
    ];
    String? validation(String key) => switch (validateProductField(key, {
      for (final entry in _fields.entries) entry.key: entry.value.text,
    }, _unit)) {
      null => null,
      ProductInputError.required => l.requiredField,
      ProductInputError.sku => l.invalidSku,
      ProductInputError.barcode => l.invalidBarcode,
      ProductInputError.hsn => l.invalidHsn,
      ProductInputError.price => l.invalidPrice,
      ProductInputError.mrp => l.invalidMrp,
      ProductInputError.quantity => l.invalidQuantity,
      ProductInputError.wholeQuantity => l.wholeQuantity,
    };
    Widget field(
      String key,
      String label,
      int maxLength, {
      int lines = 1,
      bool numeric = false,
    }) => TextFormField(
      key: ValueKey('product-$key'),
      controller: _fields[key],
      readOnly: locked,
      maxLength: maxLength,
      maxLines: lines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '',
        errorMaxLines: 4,
      ),
      validator: (_) => validation(key),
    );
    final inputs = [
      field('name', l.productName, 160),
      field('sku', l.sku, 48),
      field('barcode', l.barcode, 80),
      field('category', l.category, 80),
      field('brand', l.brand, 80),
      DropdownButtonFormField<String>(
        key: const ValueKey('product-base_unit'),
        initialValue: _unit,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l.baseUnit,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (var i = 0; i < productUnits.length; i++)
            DropdownMenuItem(
              value: productUnits[i],
              child: Text(unitLabels[i]),
            ),
        ],
        onChanged: locked || widget.product != null
            ? null
            : (value) => setState(() => _unit = value!),
      ),
      field('hsn_code', l.hsnCode, 8, numeric: true),
      field('sale_price', l.salePrice, 15, numeric: true),
      field('mrp', l.mrp, 15, numeric: true),
      field('reorder_quantity', l.reorderQuantity, 21, numeric: true),
    ];
    return PopScope(
      canPop: !_busy,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    !writable
                        ? l.productDetails
                        : widget.product == null
                        ? l.addProduct
                        : l.editProduct,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(l.baseUnitNote),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final width =
                          constraints.maxWidth >= 580 &&
                              MediaQuery.textScalerOf(context).scale(1) <= 1.3
                          ? (constraints.maxWidth - 20) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (final input in inputs)
                            SizedBox(width: width, child: input),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(l.reorderNote),
                  const SizedBox(height: 24),
                  field('description', l.description, 2000, lines: 3),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.activeProduct),
                    subtitle: Text(l.activeProductNote),
                    value: _active,
                    onChanged: locked
                        ? null
                        : (value) => setState(() => _active = value),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          switch (_error!) {
                            ErrorCode.duplicate => l.productDuplicate,
                            ErrorCode.conflict => l.productConflict,
                            ErrorCode.authorization => l.productForbidden,
                            ErrorCode.validation => l.productInvalid,
                            _ => l.productSaveError,
                          },
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(writable ? l.cancel : l.close),
                      ),
                      if (writable)
                        FilledButton(
                          onPressed:
                              _busy ||
                                  _error == ErrorCode.conflict ||
                                  _error == ErrorCode.authorization
                              ? null
                              : _save,
                          child: Text(_busy ? l.savingProduct : l.saveProduct),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
