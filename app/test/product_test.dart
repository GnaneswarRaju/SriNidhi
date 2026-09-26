import 'package:flutter_test/flutter_test.dart';
import 'package:hardware_store/features/products/domain/product.dart';
import 'package:hardware_store/features/products/domain/product_validation.dart';

void main() {
  test('exact largest prices and fractional quantities survive web-safe arithmetic', () {
    expect(
      decimalUnits('999999999999.99', scale: 2, digits: 12),
      BigInt.parse('99999999999999'),
    );
    expect(
      decimalUnits('99999999999999.999999', scale: 6, digits: 14),
      BigInt.parse('99999999999999999999'),
    );
    expect(decimalUnits('0.1', scale: 2, digits: 12), BigInt.from(10));
    for (final value in [
      '-1',
      'NaN',
      '1e2',
      '1.001',
      '1000000000000',
      '',
      '1.',
    ]) {
      expect(decimalUnits(value, scale: 2, digits: 12), isNull, reason: value);
    }
  });
  test('product rules reject fractional count units and MRP below price', () {
    expect(
      validateProductField('reorder_quantity', {
        'reorder_quantity': '0.001',
      }, 'PCS'),
      ProductInputError.wholeQuantity,
    );
    expect(
      validateProductField('reorder_quantity', {
        'reorder_quantity': '0.001',
      }, 'KG'),
      isNull,
    );
    expect(
      validateProductField('reorder_quantity', {
        'reorder_quantity': '1.000000',
      }, 'PCS'),
      isNull,
    );
    expect(
      validateProductField('mrp', {'mrp': '0.09', 'sale_price': '0.1'}, 'PCS'),
      ProductInputError.mrp,
    );
    expect(
      validateProductField('mrp', {'mrp': '0.10', 'sale_price': '0.1'}, 'PCS'),
      isNull,
    );
    expect(
      validateProductField('sku', {'sku': ' bad space '}, 'PCS'),
      ProductInputError.sku,
    );
  });
  test('create identifiers are unique UUID v4 values', () {
    final ids = List.generate(100, (_) => newProductId());
    expect(ids.toSet(), hasLength(100));
    for (final id in ids) {
      expect(
        RegExp(
          r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
        ).hasMatch(id),
        isTrue,
      );
    }
  });
}
