import 'package:supabase_flutter/supabase_flutter.dart' hide ErrorCode;

import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/product.dart';

class SupabaseProductRepository implements ProductRepository {
  SupabaseProductRepository(this.client, this.logger);
  final SupabaseClient client;
  final AppLogger logger;
  static const pageSize = 30;

  @override
  Future<ProductPage> list(CatalogueQuery query) async {
    try {
      final rows = await client.rpc(
        'catalogue_products',
        params: {
          'p_branch_id': query.branchId,
          'p_query': query.search,
          'p_show_inactive': query.inactive,
          'p_after_name': query.afterName,
          'p_after_id': query.afterId,
          'p_limit': pageSize,
        },
      ) as List;
      final products = rows
          .map((row) => Product.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
      return ProductPage(
        List.unmodifiable(products.take(pageSize)),
        products.length > pageSize,
      );
    } catch (error) {
      throw _map(error, LogOperation.loadProducts);
    }
  }

  @override
  Future<Product> save({
    required String branchId,
    required String id,
    required int? version,
    required Map<String, dynamic> data,
  }) async {
    try {
      final row = await client.rpc(
        'save_catalogue_product',
        params: {
          'p_branch_id': branchId,
          'p_product_id': id,
          'p_expected_version': version,
          'p_data': data,
        },
      );
      return Product.fromJson(Map<String, dynamic>.from(row as Map));
    } catch (error) {
      throw _map(error, LogOperation.saveProduct);
    }
  }

  AppException _map(Object error, LogOperation operation) {
    final code = switch (error) {
      PostgrestException(code: '42501') => ErrorCode.authorization,
      PostgrestException(code: '23505') => ErrorCode.duplicate,
      PostgrestException(code: '22023') => ErrorCode.validation,
      PostgrestException(code: 'P0001') => ErrorCode.conflict,
      _ => ErrorCode.network,
    };
    logger.error(LogModule.products, operation, code);
    return AppException(code);
  }
}
