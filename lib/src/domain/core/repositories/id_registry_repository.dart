import '../value_objects/namespace.dart';

/// Repository interface for managing global uniqueness of all idTypes across multiple Namespaces.
abstract class IdRegistryRepository {
  /// Registers an Namespace, checking for validation and uniqueness violations.
  ///
  /// returns [ValidationFailure] if any idCode fails validation for its idType.
  /// returns [DuplicateIdFailure] if any idType in the set conflicts
  /// with existing registrations.
  Future<void> add({required Namespace namespaceSet});

  /// Unregisters an Namespace, removing its identifiers from the registry.
  Future<void> remove({required Namespace namespaceSet});

  /// Checks if a specific idType and idCode combination is already registered.
  Future<bool> isRegistered({required Namespace namespace});

  /// Returns all registered idCodes for a given idType.
  Future<Set<Namespace>> getNamespaceByPrefix({required String prefix});
  Future<Set<Namespace>> getNamespaceByCode({required String code});

  /// Returns all idTypes that are currently registered in the registry.
  ///
  /// This includes idTypes that have registered codes, validators, or generators.
  Future<Set<Namespace>> getAll();

  /// Clears all registrations (useful for testing or resetting).
  Future<void> clear();
}
