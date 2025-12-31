import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../../core/value_objects/namespace.dart';

/// Abstract interface for asynchronous storage of ID registry data.
///
/// This allows different async persistence implementations (in-memory, database, etc.)
/// to be plugged into async versions of IdRegistry.
abstract class IdStorage {
  /// Adds an idCode to the set for the given uri asynchronously.
  Future<Either<Failure, Unit>> add({required Namespace namespace});

  /// Removes an idCode from the set for the given uri asynchronously.
  Future<Either<Failure, Unit>> remove({required Namespace namespace});

  /// Checks if the idCode exists for the given uri asynchronously.
  Future<Either<Failure, bool>> contains({required Namespace namespace});

  /// Returns all uri keys asynchronously.
  Future<Either<Failure, Set<String>>> getAllUris();

  /// Returns all idCodes for the given uri asynchronously.
  Future<Either<Failure, Set<String>>> getIdCodesForUri(Uri uri);

  /// Clears all stored data asynchronously.
  Future<Either<Failure, Unit>> clear();
}
