import 'package:hardware_store/core/errors/app_exception.dart';
import 'package:hardware_store/features/products/domain/product.dart';

const sampleProduct = Product(
  id: 'fixture-product',
  businessId: 'business-a',
  version: 1,
  nameKey: 'brass elbow 15mm',
  data: {
    'name': 'Brass elbow 15mm',
    'sku': 'BR-ELB-15',
    'barcode': '190001',
    'category': 'Pipe fittings',
    'brand': 'Fixture brand',
    'base_unit': 'PCS',
    'description': '',
    'hsn_code': '',
    'sale_price': '42.50',
    'mrp': '50.00',
    'reorder_quantity': '10.000000',
    'active': true,
  },
);

class FakeProductRepository implements ProductRepository {
  List<Product> products = [];
  final List<CatalogueQuery> queries = [];
  final List<String> savedIds = [];
  Map<String, dynamic>? savedData;
  bool fail = false;
  bool failLoad = false;
  bool paginated = false;
  @override
  Future<ProductPage> list(CatalogueQuery query) async {
    queries.add(query);
    if (failLoad) throw const AppException(ErrorCode.network);
    return ProductPage(
      products.where((p) => query.inactive || p.active).toList(),
      paginated && query.afterId == null,
    );
  }

  @override
  Future<Product> save({
    required String branchId,
    required String id,
    required int? version,
    required Map<String, dynamic> data,
  }) async {
    savedIds.add(id);
    savedData = data;
    if (fail) throw const AppException(ErrorCode.network);
    final product = Product(
      id: id,
      businessId: 'business-a',
      version: (version ?? 0) + 1,
      nameKey: (data['name'] as String).toLowerCase(),
      data: data,
    );
    products = [product];
    return product;
  }
}
