import 'package:proyecto_homero/domain/entities/product.dart';
import 'package:proyecto_homero/domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

// ¡Fíjate cómo ahora implementa la clase abstracta del dominio!
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  // El método getBeerCatalog ahora es una implementación del contrato.
  @override
  Future<List<Product>> getBeerCatalog() async {
    // Ahora delega la llamada al DataSource
    return await remoteDataSource.getProducts();
  }
}
