// lib/domain/repositories/beer_repository.dart

import 'package:proyecto_homero/domain/entities/beer.dart';

abstract class BeerRepository {
  Future<List<Beer>> getBeerCatalog();
}
