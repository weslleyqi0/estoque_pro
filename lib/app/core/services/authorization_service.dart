import 'dart:async';

import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_permission.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/repositories/users_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthorizationService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final UsersRepository _userRepository;

  AuthorizationService(
    this._firebaseAuth,
    this._userRepository,
  );

  UserEntity? _currentUser;
  bool _isLoading = false;

  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  StreamSubscription<UserEntity?>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  bool get hasUser => _currentUser != null;
  bool get isLoading => _isLoading;

  void init() {
    _authSubscription?.cancel();
    _authSubscription = _firebaseAuth.authStateChanges().listen((fbUser) async {
      if (fbUser == null) {
        _userSubscription?.cancel();
        _userSubscription = null;
        _currentUser = null;
        notifyListeners();
      } else {
        if (_currentUser?.uid != fbUser.uid) {
          _isLoading = true;
          notifyListeners();
          await loadUserProfile(fbUser.uid, fbUser.email ?? '');

          _userSubscription?.cancel();

          _userSubscription = _userRepository
              .listenUser(fbUser.uid)
              .listen(
                (user) {
                  if (user != null) {
                    _currentUser = user;
                    notifyListeners();
                  }
                },
                onError: (err) {
                  debugPrint('--> RBAC Realtime Error: $err');
                },
              );
        }
      }
    });
  }

  Future<void> loadUserProfile(String uid, String email) async {
    try {
      final userResult = await _userRepository.getUser(uid);
      final user = userResult.value;

      if (user != null) {
        _currentUser = user;
      } else {
        debugPrint(
          '--> RBAC: Usuário não encontrado em /users/$uid. Tentando provisionar como Dono (Owner) se for o primeiro acesso...',
        );
        // Tenta criar como owner. Se o banco não tiver usuários, a regra !root.child('users').exists() permitirá.
        // Se já tiver, lançará um erro de permissão negada.
        _currentUser = UserEntity(
          uid: uid,
          name: 'Dono',
          email: email,
          role: UserRole.owner,
          isActive: true,
          permissions: UserPermission.values.toSet(),
        );

        final saveResult = await _userRepository.saveUser(_currentUser!);
        if (saveResult.isSuccess) {
          debugPrint('--> RBAC: Usuário Dono (Owner) salvo com sucesso no banco.');
        } else {
          debugPrint(
            '--> RBAC: Banco de dados já possui usuários ou erro de permissão (${saveResult.error}). Provisionando como Vendedor padrão localmente.',
          );
          _currentUser = UserEntity(
            uid: uid,
            name: email.split('@').first,
            email: email,
            role: UserRole.seller,
            isActive: true,
            permissions: const {},
          );
        }
      }
    } catch (e) {
      debugPrint('--> RBAC: Erro ou Timeout ao carregar perfil: $e. Aplicando fallback de vendedor.');
      _currentUser = UserEntity(
        uid: uid,
        name: email.split('@').first,
        email: email,
        role: UserRole.seller,
        isActive: true,
        permissions: const {},
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasPermission(UserPermission permission) {
    return _currentUser?.hasPermission(permission) ?? false;
  }

  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
