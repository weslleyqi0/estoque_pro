import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/services/authorization_service.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/create_user_use_case.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/save_user_use_case.dart';

typedef CreateUserData = CreateUserParams;

class UserFormViewModel extends BaseViewModel {
  final CreateUserUseCase _createUserUseCase;
  final SaveUserUseCase _saveUserUseCase;
  final AuthorizationService _authorizationService;

  late final Command1<bool, CreateUserData> createUserCommand;
  late final Command1<bool, UserEntity> updateUserCommand;

  UserEntity? get currentUser => _authorizationService.currentUser;

  UserFormViewModel(
    this._createUserUseCase,
    this._saveUserUseCase,
    this._authorizationService,
  ) {
    createUserCommand = Command1((data) => _createUserUseCase(data));
    updateUserCommand = Command1((user) => _saveUserUseCase(user));
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
