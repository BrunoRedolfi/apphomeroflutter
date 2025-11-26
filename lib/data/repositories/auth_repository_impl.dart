import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // Si no se pasa una instancia, usa la instancia global.
  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<void> signInAnonymously() async {
    // Si ya hay un usuario, no hacemos nada y lo devolvemos.
    if (_firebaseAuth.currentUser != null) return;
    await _firebaseAuth.signInAnonymously();
  }
}