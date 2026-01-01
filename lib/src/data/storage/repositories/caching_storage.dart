import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../../../domain/storage/repositories/storage.dart';
import '../../../domain/core/value_objects/namespace.dart';

/// Decorator class that adds caching to any AsyncIdStorage implementation.
///
/// This class wraps an existing AsyncIdStorage and caches the data in memory
/// to improve performance for repeated read operations.
class CachedIdStorage implements IdStorage {
  final IdStorage _storage;
  // TODO: Implement cache invalidation strategy if needed
  // TODO: Consider cache size limits for large datasets? Different strategies?
  Set<Namespace> _cache = {};
  bool _cacheLoaded = false;

  /// Creates a CachedIdStorage that wraps the given [storage].
  CachedIdStorage({required IdStorage storage}) : _storage = storage;

  @override
  Future<Either<Failure, Unit>> add(Namespace namespace) async {
    final result = await _storage.add(namespace);
    return result.fold((failure) => Left(failure), (_) {
      // Update cache on success
      _cache.add(namespace);
      _cacheLoaded = true;
      return Right(unit);
    });
  }

  @override
  Future<Either<Failure, Unit>> remove(Namespace namespace) async {
    final result = await _storage.remove(namespace);
    return result.fold((failure) => Left(failure), (_) {
      // Update cache on success
      _cache.remove(namespace);
      return Right(unit);
    });
  }

  @override
  Future<Either<Failure, bool>> contains(Namespace namespace) async {
    // Check cache first if loaded
    if (_cacheLoaded) {
      return Right(_cache.contains(namespace));
    } else {
      // Check storage
      final result = await _storage.contains(namespace);
      return result;
    }
  }

  @override
  Future<Either<Failure, Set<Namespace>>> getAll() async {
    // Check cache first
    if (_cacheLoaded) {
      return Right(Set.from(_cache));
    } else {
      // Fetch from storage and cache
      final result = await _storage.getAll();
      return result.fold((failure) => Left(failure), (namespaces) {
        _cache = Set.from(namespaces);
        _cacheLoaded = true;
        return Right(namespaces);
      });
    }
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    final result = await _storage.clear();
    return result.fold((failure) => Left(failure), (_) {
      // Clear cache on success
      _cache.clear();
      _cacheLoaded = false;
      return Right(unit);
    });
  }
}
