import '../../domain/repositories/id_storage.dart';

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
    final codes = _cache.putIfAbsent(namespace.idType.toString(), () => {});
    codes.add(namespace.idCode);

    // Delegate to underlying storage
    await _storage.add(namespace: namespace);
  }

  @override
  Future<void> remove({required Namespace namespace}) async {
    // Update cache
    _cache[namespace.idType.toString()]?.remove(namespace.idCode);

    // Delegate to underlying storage
    await _storage.remove(namespace: namespace);
  }

  @override
  Future<bool> contains({required Namespace namespace}) async {
    // Check cache first
    if (_cache.containsKey(namespace.idType.toString())) {
      return _cache[namespace.idType.toString()]!.contains(namespace.idCode);
    } else {
      // Fetch from storage and cache
      final all = await _storage.getAll(idType: namespace.idType.toString());
      _cache[namespace.idType.toString()] = Set.from(all);
      return all.contains(namespace.idCode);
    }
  }

  @override
  Future<Set<String>> getAll({required String idType}) async {
    // Check cache first
    if (_cache.containsKey(idType)) {
      return Set.from(_cache[idType]!);
    } else {
      // Fetch from storage and cache
      final all = await _storage.getAll(idType: idType);
      _cache[idType] = Set.from(all);
      return all;
    }
  }

  @override
  Future<Set<String>> getAllTypes() async {
    // Delegate to underlying storage - no caching for all types
    return await _storage.getAllTypes();
  }

  @override
  Future<void> clear() async {
    // Clear cache
    _cache.clear();

    // Delegate to underlying storage
    await _storage.clear();
  }
}
