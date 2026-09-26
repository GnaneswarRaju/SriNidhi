import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/providers.dart';
import '../data/supabase_product_repository.dart';
import '../domain/product.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => SupabaseProductRepository(
    Supabase.instance.client,
    ref.watch(loggerProvider),
  ),
);
final productPageProvider = FutureProvider.autoDispose
    .family<ProductPage, CatalogueQuery>((ref, query) {
      ref.watch(sessionProvider);
      return ref.watch(productRepositoryProvider).list(query);
    }, retry: (_, _) => null);
