import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:estoque_pro/app/features/users/data/services/user_provisioning_service.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_entity.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/domain/usecases/save_user_use_case.dart';

typedef CreateUserParams = ({
  String name,
  String email,
  String password,
  UserRole role,
});

class CreateUserUseCase {
  final UserProvisioningService _provisioningService;
  final SaveUserUseCase _saveUserUseCase;

  const CreateUserUseCase(
    this._provisioningService,
    this._saveUserUseCase,
  );

  Future<Result<bool>> call(CreateUserParams params) async {
    final provisionResult = await _provisioningService.createUserWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );

    if (provisionResult.isFailure) {
      return Result.failure(provisionResult.error!);
    }

    final newUid = provisionResult.value!;
    final newUser = UserEntity(
      uid: newUid,
      name: params.name.trim(),
      email: params.email.trim(),
      role: params.role,
      isActive: true,
      permissions: const {},
    );

    return await _saveUserUseCase(newUser);
  }
}
