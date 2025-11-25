import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/beer.dart';

class BeerModel extends Beer {
  const BeerModel({required super.name, required super.image});

  // Factory constructor para crear una instancia de BeerModel desde un documento de Firestore
  factory BeerModel.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return BeerModel(
      name: data['name'],
      image: data['image'],
    );
  }
}
