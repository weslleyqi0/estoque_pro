import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService<T> {
  final DatabaseReference _ref;

  FirebaseDatabaseService(this._ref);

  DatabaseReference get ref => _ref;

  /// Add an item generating an automatic key (push)
  Future<void> addOrUpdate(Map<String, dynamic> data) async {
    final newRef = _ref.push();

    final dataWithId = {
      ...data,
      'id': newRef.key,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await newRef.set(dataWithId);
  }

  /// Adds/updates on a specific key
  Future<void> update(String key, Map<String, dynamic> data) async {
    await _ref.child(key).set({
      ...data,
      "updatedAt": DateTime.now().toIso8601String(),
    });
  }

  /// Remove an item by ID
  Future<void> delete(String key) async {
    await _ref.child(key).remove();
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
    final snapshot = await _ref.get();
    if (snapshot.exists && snapshot.value is Map) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  /// Fetch child data only once
  Future<Map<String, dynamic>?> getChildOnce(String key) async {
    final snapshot = await _ref.child(key).get();
    if (snapshot.exists && snapshot.value is Map) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }
}
