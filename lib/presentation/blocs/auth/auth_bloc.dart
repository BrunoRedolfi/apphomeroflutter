import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_homero/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    on<AuthAnonymousSignInRequested>(_onAnonymousSignInRequested);

    // Escuchamos los cambios de estado de Firebase para actualizar nuestro BLoC
    _userSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  Future<void> _onAnonymousSignInRequested(AuthAnonymousSignInRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signInAnonymously();
  }
}
