import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  // Inicia sesión de forma anónima.
  Future<void> signInAnonymously();

  /// Un stream que notifica los cambios en el estado de autenticación (login, logout).
  Stream<User?> get authStateChanges;
}