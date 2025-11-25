import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/beer_model.dart';

abstract class BeerRemoteDataSource {
  Future<List<BeerModel>> getBeers();
}

class BeerRemoteDataSourceImpl implements BeerRemoteDataSource {
  final FirebaseFirestore firestore;

  BeerRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<BeerModel>> getBeers() async {
    final snapshot = await firestore.collection('beers').get();
    return snapshot.docs.map((doc) => BeerModel.fromSnapshot(doc)).toList();
  }
}
