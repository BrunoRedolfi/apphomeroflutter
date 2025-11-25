import 'package:proyecto_homero/domain/entities/beer.dart';
import 'package:proyecto_homero/domain/repositories/beer_repository.dart';
import '../datasources/beer_remote_datasource.dart';

// ¡Fíjate cómo ahora implementa la clase abstracta del dominio!
class BeerRepositoryImpl implements BeerRepository {
  final BeerRemoteDataSource remoteDataSource;

  BeerRepositoryImpl({required this.remoteDataSource});

  // El método getBeerCatalog ahora es una implementación del contrato.
  @override
  Future<List<Beer>> getBeerCatalog() async {
    // Ahora delega la llamada al DataSource
    return await remoteDataSource.getBeers();
  }
}
