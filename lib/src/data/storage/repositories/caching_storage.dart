import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../../../data/core/models/namespace_dto.dart';
import '../../../domain/storage/repositories/storage.dart';

/// Decorator class that adds caching to any AsyncIdStorage implementation.
///
/// This class wraps an existing AsyncIdStorage and caches the data in memory
/// to improve performance for repeated read operations.
class CachedIdStorage implements IdStorage {
  final IdStorage _storage;
  // TODO: Implement cache invalidation strategy if needed
  // TODO: Consider cache size limits for large datasets? Different strategies?
  Set<NamespaceDto> _cache = {};
  bool _cacheLoaded = false;

  /// Creates a CachedIdStorage that wraps the given [storage].
  CachedIdStorage({required IdStorage storage}) : _storage = storage;

  @override
  Future<Either<Failure, Unit>> add(NamespaceDto dto) async {
    final result = await _storage.add(dto);
    return result.fold((failure) => Left(failure), (_) {
      // Update cache on success
      _cache.add(dto);
      _cacheLoaded = true;
      return Right(unit);
    });
  }

  @override
  Future<Either<Failure, Unit>> remove(NamespaceDto dto) async {
    final result = await _storage.remove(dto);
    return result.fold((failure) => Left(failure), (_) {
      // Update cache on success
      _cache.remove(dto);
      return Right(unit);
    });
  }

  @override
  Future<Either<Failure, bool>> contains(NamespaceDto dto) async {
    // Check cache first if loaded
    if (_cacheLoaded) {
      return Right(_cache.contains(dto));
    } else {
      // Check storage
      final result = await _storage.contains(dto);
      return result;
    }
  }

  @override
  Future<Either<Failure, Set<NamespaceDto>>> getAll() async {
    // Check cache first
    if (_cacheLoaded) {
      return Right(Set.from(_cache));
    } else {
      // Fetch from storage and cache
      final result = await _storage.getAll();
      return result.fold((failure) => Left(failure), (dtos) {
        _cache = Set.from(dtos);
        _cacheLoaded = true;
        return Right(dtos);
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
