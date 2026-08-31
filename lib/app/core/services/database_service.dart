import 'package:firebase_database/firebase_database.dart';

/// Generic database service interface abstracting real-time database
/// and CRUD operations.
abstract class DatabaseService<T> {
  DatabaseReference get ref;

  /// Add an item generating an automatic key (push)
  Future<void> add(Map<String, dynamic> data);

  /// Adds/updates on a specific key
  Future<void> update(String key, Map<String, dynamic> data);

  /// Perform a multi-path atomic update at the root
  Future<void> updateMultiple(Map<String, dynamic> updates);

  /// Remove an item by ID
  Future<void> delete(String key);

  /// Listen to changes in real time
  Stream<Map<String, dynamic>?> listen();

  /// Listen to changes in real time for a specific child
  Stream<Map<String, dynamic>?> listenChild(String key);

  /// Fetch data only once
  Future<Map<String, dynamic>?> getOnce();

  /// Fetch child data only once
  Future<Map<String, dynamic>?> getChildOnce(String key);
}
