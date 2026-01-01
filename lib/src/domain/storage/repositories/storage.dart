import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../../core/value_objects/namespace.dart';

/// Abstract interface for asynchronous storage of ID registry data.
///
/// This allows different async persistence implementations (in-memory, database, etc.)
/// to be plugged into async versions of IdRegistry.
abstract class IdStorage {
  /// Adds a namespace asynchronously.
  Future<Either<Failure, Unit>> add(Namespace namespace);

  /// Removes a namespace asynchronously.
  Future<Either<Failure, Unit>> remove(Namespace namespace);

  /// Checks if the namespace exists asynchronously.
  Future<Either<Failure, bool>> contains(Namespace namespace);

  /// Returns all stored namespaces asynchronously.
  Future<Either<Failure, Set<Namespace>>> getAll();

  /// Clears all stored data asynchronously.
  Future<Either<Failure, Unit>> clear();
}
