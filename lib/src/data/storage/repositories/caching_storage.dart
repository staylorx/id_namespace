import 'package:fpdart/fpdart.dart';

import '../../../domain/core/failures.dart';
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
  Future<Either<Failure, Unit>> add({required Namespace namespace}) async {
    final result = await _storage.add(namespace: namespace);
    return result.fold(
      (failure) => Left(failure),
      (_) {
        // Update cache on success
        final codes = _cache.putIfAbsent(namespace.uri.toString(), () => {});
        codes.add(namespace.prefix);
        return Right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> remove({required Namespace namespace}) async {
    final result = await _storage.remove(namespace: namespace);
    return result.fold(
      (failure) => Left(failure),
      (_) {
        // Update cache on success
        _cache[namespace.uri.toString()]?.remove(namespace.prefix);
        return Right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> contains({required Namespace namespace}) async {
    final uriKey = namespace.uri.toString();
    // Check cache first
    if (_cache.containsKey(uriKey)) {
      return Right(_cache[uriKey]!.contains(namespace.prefix));
    } else {
      // Fetch from storage and cache
      final codesResult = await _storage.getIdCodesForUri(namespace.uri);
      return codesResult.fold(
        (failure) => Left(failure),
        (codes) {
          _cache[uriKey] = codes;
          return Right(codes.contains(namespace.prefix));
        },
      );
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getAllUris() async {
    // Delegate to underlying storage - no caching for all uris
    return await _storage.getAllUris();
  }

  @override
  Future<Either<Failure, Set<String>>> getIdCodesForUri(Uri uri) async {
    final uriKey = uri.toString();
    // Check cache first
    if (_cache.containsKey(uriKey)) {
      return Right(_cache[uriKey]!);
    } else {
      // Fetch from storage and cache
      final codesResult = await _storage.getIdCodesForUri(uri);
      return codesResult.fold(
        (failure) => Left(failure),
        (codes) {
          _cache[uriKey] = codes;
          return Right(codes);
        },
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    final result = await _storage.clear();
    return result.fold(
      (failure) => Left(failure),
      (_) {
        // Clear cache on success
        _cache.clear();
        return Right(unit);
      },
    );
  }
}
