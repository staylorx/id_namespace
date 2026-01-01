import 'package:fpdart/fpdart.dart';

import '../../../domain/storage/repositories/storage.dart';
import '../../../utils/failures.dart';
import '../../../data/core/models/namespace_dto.dart';
import '../../../domain/core/value_objects/namespace.dart';

/// In-memory implementation of AsyncIdStorage using `Set<NamespaceDto>`.
///
/// This is the async version of InMemoryIdStorage, wrapping synchronous operations in Futures.
class InMemoryIdStorage implements IdStorage {
  final Set<NamespaceDto> _data = {};

  /// Adds the namespace.
  @override
  Future<Either<Failure, Unit>> add(Namespace namespace) async {
    final dto = NamespaceDto.fromEntity(namespace);
    if (_data.contains(dto)) {
      return Left(
        DuplicateIdFailure(prefix: dto.prefix, uri: Uri.parse(dto.uri)),
      );
    }
    _data.add(dto);
    return Right(unit);
  }

  /// Removes the namespace.
  @override
  Future<Either<Failure, Unit>> remove(Namespace namespace) async {
    final dto = NamespaceDto.fromEntity(namespace);
    _data.remove(dto);
    return Right(unit);
  }

  /// Checks if the namespace exists.
  @override
  Future<Either<Failure, bool>> contains(Namespace namespace) async {
    final dto = NamespaceDto.fromEntity(namespace);
    return Right(_data.contains(dto));
  }

  /// Returns all stored namespaces.
  @override
  Future<Either<Failure, Set<Namespace>>> getAll() async {
    return Right(_data.map((dto) => dto.toEntity()).toSet());
  }

  /// Clears all data.
  @override
  Future<Either<Failure, Unit>> clear() async {
    _data.clear();
    return Right(unit);
  }
}
