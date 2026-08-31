import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../errors/app_failure.dart';
import '../logger/app_logger.dart';

class FirebaseDatabaseService<T> {
  final DatabaseReference _ref;
  final AppLogger _logger = const AppLogger('FirebaseDatabaseService');

  FirebaseDatabaseService(this._ref);

  DatabaseReference get ref => _ref;

  Future<R> _handleError<R>(Future<R> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e, stackTrace) {
      _logger.e(
        'FirebaseException [${e.code}]: ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );
      throw switch (e.code) {
        'permission-denied' => PermissionFailure(
            message: 'Você não tem permissão para realizar esta operação.',
            code: e.code,
            error: e,
            stackTrace: stackTrace,
          ),
        'disconnected' => NetworkFailure(
            message: 'Sem conexão com a internet. Tente novamente mais tarde.',
            code: e.code,
            error: e,
            stackTrace: stackTrace,
          ),
        'network-error' => NetworkFailure(
            message: 'Erro de rede. Verifique sua conexão.',
            code: e.code,
            error: e,
            stackTrace: stackTrace,
          ),
        'unavailable' => DatabaseFailure(
            message: 'O serviço de banco de dados está indisponível.',
            code: e.code,
            error: e,
            stackTrace: stackTrace,
          ),
        'write-canceled' => DatabaseFailure(
            message: 'A operação foi cancelada pelo servidor.',
            code: e.code,
            error: e,
            stackTrace: stackTrace,
          ),
        _ => DatabaseFailure(
            message: e.message ?? 'Ocorreu um erro inesperado: ${e.message}',
            code: e.code,
            error: e,
            stackTrace: stackTrace,
          ),
      };
    } on AppFailure {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e(
        'Unknown Exception: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnknownFailure(
        message: 'Ocorreu um erro: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Add an item generating an automatic key (push)
  Future<void> add(Map<String, dynamic> data) async {
    return _handleError(() async {
      final newRef = _ref.push();

      final dataWithId = {
        ...data,
        'id': newRef.key,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      };

      await newRef.set(dataWithId);
    });
  }

  /// Adds/updates on a specific key
  Future<void> update(String key, Map<String, dynamic> data) async {
    return _handleError(() async {
      await _ref.child(key).update({
        ...data,
        "updatedAt": ServerValue.timestamp,
      });
    });
  }

  /// Perform a multi-path atomic update at the root
  Future<void> updateMultiple(Map<String, dynamic> updates) async {
    return _handleError(() async {
      await _ref.root.update(updates);
    });
  }

  /// Remove an item by ID
  Future<void> delete(String key) async {
    return _handleError(() async {
      await _ref.child(key).remove();
    });
  }

  /// Listen to changes in real time
  Stream<Map<String, dynamic>?> listen() {
    return _ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    });
  }

  /// Listen to changes in real time for a specific child
  Stream<Map<String, dynamic>?> listenChild(String key) {
    return _ref.child(key).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        return Map<String, dynamic>.from(value);
      }
      return null;
    });
  }

  /// Fetch data only once
  Future<Map<String, dynamic>?> getOnce() async {
    return _handleError(() async {
      final snapshot = await _ref.get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    });
  }

  /// Fetch child data only once
  Future<Map<String, dynamic>?> getChildOnce(String key) async {
    return _handleError(() async {
      final snapshot = await _ref.child(key).get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    });
  }
}
