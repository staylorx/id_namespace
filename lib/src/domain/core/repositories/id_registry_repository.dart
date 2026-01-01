import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../value_objects/namespace.dart';

/// Repository interface for managing global uniqueness of all idTypes across multiple Namespaces.
abstract class IdRegistryRepository {
  /// Registers an Namespace, checking for validation and uniqueness violations.
  ///
  /// returns [ValidationFailure] if any idCode fails validation for its uri.
  /// returns [DuplicateIdFailure] if any uri in the set conflicts
  /// with existing registrations.
  Future<Either<Failure, Unit>> add({required Namespace namespace});

  /// Unregisters an Namespace, removing its identifiers from the registry.
  Future<Either<Failure, Unit>> remove({required Namespace namespace});

  /// Checks if a specific uri and idCode combination is already registered.
  Future<Either<Failure, bool>> isRegistered({required Namespace namespace});

  /// Returns the registered namespace for a given prefix.
  Future<Either<Failure, Namespace>> getNamespaceByPrefix({
    required String prefix,
  });
  Future<Either<Failure, Namespace>> getNamespaceByCode({
    required String code,
  });

  /// Returns all idTypes that are currently registered in the registry.
  ///
  /// This includes idTypes that have registered codes, validators, or generators.
  Future<Either<Failure, Set<Namespace>>> getAll();

  /// Clears all registrations (useful for testing or resetting).
  Future<Either<Failure, Unit>> clear();

  /// Fetches an ontology file from the internet and registers it in the namespace registry.
  ///
  /// Fetches the content from [url], parses it as RDF, and registers a new namespace
  /// with the provided [prefix]. The URI is derived from the URL.
  /// Returns [NetworkFailure] if fetching fails, [ParseFailure] if parsing fails,
  /// or other failures from registration.
  Future<Either<Failure, Unit>> fetchAndRegisterOntology({
    required String url,
    required String prefix,
    String? description,
  });

  /// Fetches the content of an ontology from the given URL.
  ///
  /// Supports both file:// and http/https URLs.
  /// Returns [NetworkFailure] if fetching fails.
  Future<Either<Failure, String>> fetchOntologyContent({
    required String url,
  });
}
