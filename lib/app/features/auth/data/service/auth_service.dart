import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/auth/domain/entities/auth_user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Stream<AuthUserEntity?> get authStateChanges;
  AuthUserEntity? get currentUser;

  Future<Result<AuthUserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();
}

class AuthServiceImpl implements AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthServiceImpl([FirebaseAuth? firebaseAuth])
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  AuthUserEntity? _toEntity(User? user) {
    if (user == null) return null;
    return AuthUserEntity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges => _firebaseAuth.authStateChanges().map(_toEntity);

  @override
  AuthUserEntity? get currentUser => _toEntity(_firebaseAuth.currentUser);

  @override
  Future<Result<AuthUserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final entity = _toEntity(credential.user);
      if (entity == null) {
        return Result.failure(Exception('Usuário não encontrado.'));
      }
      return Result.success(entity);
    } on FirebaseAuthException catch (e, stackTrace) {
      final message = switch (e.code) {
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'E-mail ou senha incorretos.',
        'invalid-email' => 'O formato do e-mail é inválido.',
        'user-disabled' => 'Esta conta de usuário foi desativada.',
        'too-many-requests' => 'Muitas tentativas bloqueadas. Tente novamente mais tarde.',
        'network-request-failed' => 'Falha na conexão de rede. Verifique sua conexão com a internet.',
        _ => e.message ?? 'Ocorreu um erro ao realizar o login.',
      };
      return Result.failure(Exception(message), stackTrace);
    } catch (e, stackTrace) {
      return Result.failure(Exception('Erro inesperado: $e'), stackTrace);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Result.success(null);
    } catch (e, stackTrace) {
      return Result.failure(Exception(e.toString()), stackTrace);
    }
  }
}
