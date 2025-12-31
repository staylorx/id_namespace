import '../../../domain/storage/repositories/storage.dart';

/// In-memory implementation of AsyncIdStorage using `Map<String, Set<String>>`.
///
/// This is the async version of InMemoryIdStorage, wrapping synchronous operations in Futures.
class InMemoryIdStorage implements IdStorage {
  final Map<String, Set<String>> _data = {};
  final Map<String, int> _counters = {};

  @override
  Future<void> add({required Namespace namespace}) async {
    final codes = _data.putIfAbsent(namespace.idType.toString(), () => {});
    codes.add(namespace.idCode);
  }

  @override
  Future<void> remove({required Namespace namespace}) async {
    _data[namespace.idType.toString()]?.remove(namespace.idCode);
  }

  @override
  Future<bool> contains({required Namespace namespace}) async {
    return _data[namespace.idType.toString()]?.contains(namespace.idCode) ??
        false;
  }

  @override
  Future<Set<String>> getAll({required String idType}) async {
    return Set.from(_data[idType] ?? {});
  }

  @override
  Future<Set<String>> getAllTypes() async {
    return Set.from(_data.keys);
  }

  @override
  Future<void> clear() async {
    _data.clear();
    _counters.clear();
  }
}
