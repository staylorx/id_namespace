import '../../../domain/core/value_objects/namespace.dart';
import '../../../domain/storage/repositories/storage.dart';

/// Decorator class that adds caching to any AsyncIdStorage implementation.
///
/// This class wraps an existing AsyncIdStorage and caches the data in memory
/// to improve performance for repeated read operations.
class CachedIdStorage implements IdStorage {
  final IdStorage _storage;
  // TODO: Implement cache invalidation strategy if needed
  // TODO: Consider cache size limits for large datasets? Different strategies?
  final Map<String, Set<String>> _cache = {};

  /// Creates a CachedIdStorage that wraps the given [storage].
  CachedIdStorage({required IdStorage storage}) : _storage = storage;

  @override
  Future<void> add({required Namespace namespace}) async {
    // Update cache
    final codes = _cache.putIfAbsent(namespace.uri.toString(), () => {});
    codes.add(namespace.idCode);

    // Delegate to underlying storage
    await _storage.add(namespace: namespace);
  }

  @override
  Future<void> remove({required Namespace namespace}) async {
    // Update cache
    _cache[namespace.uri.toString()]?.remove(namespace.idCode);

    // Delegate to underlying storage
    await _storage.remove(namespace: namespace);
  }

  @override
  Future<bool> contains({required Namespace namespace}) async {
    // Check cache first
    if (_cache.containsKey(namespace.uri.toString())) {
      return _cache[namespace.uri.toString()]!.contains(namespace.idCode);
    } else {
      // Fetch from storage and cache
      final all = await _storage.getAll();
      _cache[namespace.uri.toString()] = Set.from(all);
      return all.contains(namespace.idCode);
    }
  }

  @override
  Future<Set<String>> getAll() async {
    // Delegate to underlying storage - no caching for all types
    return await _storage.getAll();
  }

  @override
  Future<void> clear() async {
    // Clear cache
    _cache.clear();

    // Delegate to underlying storage
    await _storage.clear();
  }
}
