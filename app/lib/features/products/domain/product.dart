import 'dart:math';

import '../../workspace/domain/branch_membership.dart';

/// Decimal strings stay exact across JSON, Dart/JavaScript and PostgreSQL.
BigInt? decimalUnits(String value, {required int scale, required int digits}) {
  if (!RegExp('^[0-9]{1,$digits}(\\.[0-9]{1,$scale})?\$').hasMatch(value)) {
    return null;
  }
  final parts = value.split('.');
  return BigInt.parse(
    parts[0] + (parts.length == 2 ? parts[1] : '').padRight(scale, '0'),
  );
}

String newProductId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((n) => n.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

bool canManageProducts(BranchMembership branch) => branch.roles.any(
  {
    StoreRole.owner,
    StoreRole.admin,
    StoreRole.manager,
    StoreRole.stockManager,
  }.contains,
);

const productUnits = [
  'PCS',
  'BOX',
  'PACK',
  'BAG',
  'SET',
  'ROLL',
  'KG',
  'G',
  'M',
  'CM',
  'FT',
  'L',
  'ML',
];
const wholeProductUnits = {'PCS', 'BOX', 'PACK', 'BAG', 'SET', 'ROLL'};

class Product {
  const Product({
    required this.id,
    required this.businessId,
    required this.version,
    required this.nameKey,
    required this.data,
  });
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    businessId: json['business_id'] as String,
    version: json['version'] as int,
    nameKey: json['name_key'] as String,
    data: Map.unmodifiable({for (final key in fields) key: json[key]}),
  );
  static const fields = [
    'name',
    'sku',
    'barcode',
    'category',
    'brand',
    'base_unit',
    'description',
    'hsn_code',
    'sale_price',
    'mrp',
    'reorder_quantity',
    'active',
  ];
  final String id;
  final String businessId;
  final int version;
  final String nameKey;
  final Map<String, dynamic> data;
  String text(String key) => data[key] as String? ?? '';
  bool get active => data['active'] as bool;
}

typedef CatalogueQuery = ({
  String branchId,
  String search,
  bool inactive,
  String? afterName,
  String? afterId,
});

class ProductPage {
  const ProductPage(this.items, this.hasMore);
  final List<Product> items;
  final bool hasMore;
}

abstract interface class ProductRepository {
  Future<ProductPage> list(CatalogueQuery query);
  Future<Product> save({
    required String branchId,
    required String id,
    required int? version,
    required Map<String, dynamic> data,
  });
}
