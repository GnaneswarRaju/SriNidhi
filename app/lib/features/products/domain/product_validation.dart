import 'product.dart';

enum ProductInputError {
  required,
  sku,
  barcode,
  hsn,
  price,
  mrp,
  quantity,
  wholeQuantity,
}

/// Presentation maps these stable errors to translated text. Monetary and
/// quantity comparisons never use binary floating point, including on web.
ProductInputError? validateProductField(
  String key,
  Map<String, String> values,
  String unit,
) {
  final value = (values[key] ?? '').trim();
  switch (key) {
    case 'name':
      return value.isEmpty ? ProductInputError.required : null;
    case 'sku':
      return RegExp(r'^[A-Za-z0-9][A-Za-z0-9._/-]{0,47}$').hasMatch(value)
          ? null
          : ProductInputError.sku;
    case 'barcode':
      return value.isEmpty || RegExp(r'^[A-Za-z0-9._/-]{1,80}$').hasMatch(value)
          ? null
          : ProductInputError.barcode;
    case 'hsn_code':
      return value.isEmpty || RegExp(r'^[0-9]{4,8}$').hasMatch(value)
          ? null
          : ProductInputError.hsn;
    case 'sale_price':
      return decimalUnits(value, scale: 2, digits: 12) == null
          ? ProductInputError.price
          : null;
    case 'mrp':
      if (value.isEmpty) return null;
      final maximum = decimalUnits(value, scale: 2, digits: 12);
      if (maximum == null) return ProductInputError.price;
      final selling = decimalUnits(
        (values['sale_price'] ?? '').trim(),
        scale: 2,
        digits: 12,
      );
      return selling != null && maximum < selling
          ? ProductInputError.mrp
          : null;
    case 'reorder_quantity':
      final quantity = decimalUnits(value, scale: 6, digits: 14);
      if (quantity == null) return ProductInputError.quantity;
      return wholeProductUnits.contains(unit) &&
              quantity % BigInt.from(1000000) != BigInt.zero
          ? ProductInputError.wholeQuantity
          : null;
    default:
      return null;
  }
}
