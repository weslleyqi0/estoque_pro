import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FirebaseDatabaseService<T> {
  final DatabaseReference _ref;

  FirebaseDatabaseService(this._ref);

  DatabaseReference get ref => _ref;

  Future<T> _handleError<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException [${e.code}]: ${e.message}');
      switch (e.code) {
        case 'permission-denied':
          throw Exception('Você não tem permissão para realizar esta operação.');
        case 'disconnected':
          throw Exception('Sem conexão com a internet. Tente novamente mais tarde.');
        case 'network-error':
          throw Exception('Erro de rede. Verifique sua conexão.');
        case 'unavailable':
          throw Exception('O serviço de banco de dados está indisponível.');
        case 'write-canceled':
          throw Exception('A operação foi cancelada pelo servidor.');
        default:
          throw Exception('Ocorreu um erro inesperado: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unknown Exception: $e');
      throw Exception('Ocorreu um erro: $e');
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
