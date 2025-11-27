// lib/domain/repositories/beer_repository.dart

import 'package:proyecto_homero/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getBeerCatalog();
}
