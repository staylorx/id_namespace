import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../../../data/core/models/namespace_dto.dart';

/// Abstract interface for asynchronous storage of ID registry data.
///
/// This allows different async persistence implementations (in-memory, database, etc.)
/// to be plugged into async versions of IdRegistry.
// TODO: Should these use Namespace entities directly instead of DTOs?
abstract class IdStorage {
  /// Adds a namespace DTO asynchronously.
  Future<Either<Failure, Unit>> add(NamespaceDto dto);

  /// Removes a namespace DTO asynchronously.
  Future<Either<Failure, Unit>> remove(NamespaceDto dto);

  /// Checks if the namespace DTO exists asynchronously.
  Future<Either<Failure, bool>> contains(NamespaceDto dto);

  /// Returns all stored namespace DTOs asynchronously.
  Future<Either<Failure, Set<NamespaceDto>>> getAll();

  /// Clears all stored data asynchronously.
  Future<Either<Failure, Unit>> clear();
}
