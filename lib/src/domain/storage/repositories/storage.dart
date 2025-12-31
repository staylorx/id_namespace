import '../../core/value_objects/namespace.dart';

/// Abstract interface for asynchronous storage of ID registry data.
///
/// This allows different async persistence implementations (in-memory, database, etc.)
/// to be plugged into async versions of IdRegistry.
abstract class IdStorage {
  /// Adds an idCode to the set for the given idType asynchronously.
  Future<void> add({required Namespace namespace});

  /// Removes an idCode from the set for the given idType asynchronously.
  Future<void> remove({required Namespace namespace});

  /// Checks if the idCode exists for the given idType asynchronously.
  Future<bool> contains({required Namespace namespace});

  /// Returns all idCodes for the given idType asynchronously.
  Future<Set<String>> getAll();

  /// Clears all stored data asynchronously.
  Future<void> clear();

  /// Returns all idTypes that have registered codes asynchronously.
  Future<Set<String>> getAllTypes();
}
