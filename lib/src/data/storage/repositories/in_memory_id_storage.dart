import 'package:fpdart/fpdart.dart';

import '../../../domain/storage/repositories/storage.dart';
import '../../../domain/core/failures.dart';
import '../../../domain/core/value_objects/namespace.dart';

/// In-memory implementation of AsyncIdStorage using `Map<String, Set<String>>`.
///
/// This is the async version of InMemoryIdStorage, wrapping synchronous operations in Futures.
class InMemoryIdStorage implements IdStorage {
  final Map<String, Set<String>> _data = {};
  final Map<String, int> _counters = {};

  @override
  Future<Either<Failure, Unit>> add({required Namespace namespace}) async {
    final uriKey = namespace.uri.toString();
    final codes = _data.putIfAbsent(uriKey, () => {});
    if (codes.contains(namespace.prefix)) {
      return Left(DuplicateIdFailure(namespace.prefix, namespace.uri));
    }
    codes.add(namespace.prefix);
    return Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> remove({required Namespace namespace}) async {
    _data[namespace.uri.toString()]?.remove(namespace.prefix);
    return Right(unit);
  }

  @override
  Future<Either<Failure, bool>> contains({required Namespace namespace}) async {
    return Right(
      _data[namespace.uri.toString()]?.contains(namespace.prefix) ?? false,
    );
  }

  @override
  Future<Either<Failure, Set<String>>> getAllUris() async {
    return Right(Set.from(_data.keys));
  }

  @override
  Future<Either<Failure, Set<String>>> getIdCodesForUri(Uri uri) async {
    return Right(_data[uri.toString()] ?? {});
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    _data.clear();
    _counters.clear();
    return Right(unit);
  }
}
