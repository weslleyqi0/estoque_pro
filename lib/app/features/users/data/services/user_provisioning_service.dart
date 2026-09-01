import 'package:estoque_pro/app/core/utils/result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class UserProvisioningService {
  Future<Result<String>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
}

class UserProvisioningServiceImpl implements UserProvisioningService {
  @override
  Future<Result<String>> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    FirebaseApp? tempApp;
    try {
      final appName = 'UserProvisioningApp_${DateTime.now().millisecondsSinceEpoch}';
      tempApp = await Firebase.initializeApp(
        name: appName,
        options: Firebase.app().options,
      );

      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final newUid = userCredential.user?.uid;
      if (newUid == null) {
        return Result.failure(Exception('Falha ao obter identificador do novo usuário.'));
      }

      return Result.success(newUid);
    } on FirebaseAuthException catch (e, stackTrace) {
      final message = switch (e.code) {
        'email-already-in-use' => 'Este e-mail já está cadastrado no sistema.',
        'weak-password' => 'A senha deve conter no mínimo 6 caracteres.',
        'invalid-email' => 'O e-mail informado é inválido.',
        _ => e.message ?? 'Erro ao criar usuário no Firebase Auth.',
      };
      return Result.failure(Exception(message), stackTrace);
    } catch (e, stackTrace) {
      return Result.failure(Exception(e.toString()), stackTrace);
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }
}
