import 'dart:async';

import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/save_user_use_case.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

typedef CreateUserData = ({
  String name,
  String email,
  String password,
  UserRole role,
});

class UserFormViewModel extends BaseViewModel {
  final SaveUserUseCase _saveUserUseCase;
  final AuthorizationService _authorizationService;

  late final Command1<bool, CreateUserData> createUserCommand;
  late final Command1<bool, UserEntity> updateUserCommand;

  UserEntity? get currentUser => _authorizationService.currentUser;

  UserFormViewModel(
    this._saveUserUseCase,
    this._authorizationService,
  ) {
    createUserCommand = Command1(_createUser);
    updateUserCommand = Command1((user) => _saveUserUseCase(user));
  }

  Future<Result<bool>> _createUser(CreateUserData data) async {
    FirebaseApp? tempApp;
    try {
      final appName = 'UserProvisioningApp_${DateTime.now().millisecondsSinceEpoch}';
      tempApp = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );

      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: data.email.trim(),
        password: data.password.trim(),
      );

      final newUid = userCredential.user!.uid;

      final newUser = UserEntity(
        uid: newUid,
        name: data.name.trim(),
        email: data.email.trim(),
        role: data.role,
        isActive: true,
        permissions: const {},
      );

      return await _saveUserUseCase(newUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return Failure(Exception('Este e-mail já está cadastrado no sistema.'));
      } else if (e.code == 'weak-password') {
        return Failure(Exception('A senha deve conter no mínimo 6 caracteres.'));
      } else if (e.code == 'invalid-email') {
        return Failure(Exception('O e-mail informado é inválido.'));
      }
      return Failure(Exception(e.message ?? 'Erro ao criar usuário no Firebase Auth.'));
    } catch (e) {
      return Failure(Exception(e.toString()));
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  bool canEdit(UserEntity targetUser) {
    final current = currentUser;
    if (current == null) return false;
    if (current.role == UserRole.owner) return true;
    if (current.role == UserRole.admin) {
      return targetUser.role != UserRole.owner;
    }
    return false;
  }
}
