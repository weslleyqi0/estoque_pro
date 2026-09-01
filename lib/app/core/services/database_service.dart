/// Generic database service interface abstracting real-time database
/// and CRUD operations without leaking third-party SDK types.
abstract class DatabaseService<T> {
  /// Generate a unique push key (optionally under a sub-path)
  String pushKey([String? subPath]);

  /// Database-agnostic representation of server timestamp
  Object get serverTimestamp;

  /// Database-agnostic atomic increment
  Object increment(num value);

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

  /// Listen with order and limit filters
  Stream<Map<String, dynamic>?> listenOrdered({
    String? subPath,
    String? orderByChild,
    int? limitToLast,
  });

  /// Fetch data only once
  Future<Map<String, dynamic>?> getOnce();

  /// Fetch child data only once
  Future<Map<String, dynamic>?> getChildOnce(String key);

  /// Query once with order, filter, and limit
  Future<Map<String, dynamic>?> queryOnce({
    String? subPath,
    String? orderByChild,
    dynamic equalTo,
    int? limitToLast,
    Duration? timeout,
  });
}
