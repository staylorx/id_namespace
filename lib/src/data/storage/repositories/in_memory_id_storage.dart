import 'package:fpdart/fpdart.dart';

import '../../../domain/storage/repositories/storage.dart';
import '../../../utils/failures.dart';
import '../../../data/core/models/namespace_dto.dart';

/// In-memory implementation of AsyncIdStorage using `Set<NamespaceDto>`.
///
/// This is the async version of InMemoryIdStorage, wrapping synchronous operations in Futures.
class InMemoryIdStorage implements IdStorage {
  final Set<NamespaceDto> _data = {};

  /// Adds the namespace DTO.
  @override
  Future<Either<Failure, Unit>> add(NamespaceDto dto) async {
    if (_data.contains(dto)) {
      return Left(
        DuplicateIdFailure(prefix: dto.prefix, uri: Uri.parse(dto.uri)),
      );
    }
    _data.add(dto);
    return Right(unit);
  }

  /// Removes the namespace DTO.
  @override
  Future<Either<Failure, Unit>> remove(NamespaceDto dto) async {
    _data.remove(dto);
    return Right(unit);
  }

  /// Checks if the namespace DTO exists.
  @override
  Future<Either<Failure, bool>> contains(NamespaceDto dto) async {
    return Right(_data.contains(dto));
  }

  /// Returns all stored namespace DTOs.
  @override
  Future<Either<Failure, Set<NamespaceDto>>> getAll() async {
    return Right(Set.from(_data));
  }

  /// Clears all data.
  @override
  Future<Either<Failure, Unit>> clear() async {
    _data.clear();
    return Right(unit);
  }
}
