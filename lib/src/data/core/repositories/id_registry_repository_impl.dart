import 'package:fpdart/fpdart.dart';

import 'package:id_namespace/src/utils/failures.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';

/// Implementation of IdRegistryRepository using IdStorage.
class IdRegistryRepositoryImpl implements IdRegistryRepository {
  final IdStorage storage;

  IdRegistryRepositoryImpl({required this.storage});

  /// Registers the namespace.
  @override
  Future<Either<Failure, Unit>> add({required Namespace namespace}) async {
    return await storage.add(namespace: namespace);
  }

  /// Unregisters the namespace.
  @override
  Future<Either<Failure, Unit>> remove({required Namespace namespace}) async {
    return await storage.remove(namespace: namespace);
  }

  /// Checks if the namespace is registered.
  @override
  Future<Either<Failure, bool>> isRegistered({
    required Namespace namespace,
  }) async {
    return await storage.contains(namespace: namespace);
  }

  /// Returns namespaces by prefix.
  @override
  Future<Either<Failure, Set<Namespace>>> getNamespaceByPrefix({
    required String prefix,
  }) async {
    final allResult = await getAll();
    return allResult.fold(
      (failure) => Left(failure),
      (allNamespaces) => Right(
        allNamespaces
            .where((namespace) => namespace.prefix.startsWith(prefix))
            .toSet(),
      ),
    );
  }

  /// Returns namespaces by code.
  @override
  Future<Either<Failure, Set<Namespace>>> getNamespaceByCode({
    required String code,
  }) async {
    final allResult = await getAll();
    return allResult.fold(
      (failure) => Left(failure),
      (allNamespaces) => Right(
        allNamespaces.where((namespace) => namespace.prefix == code).toSet(),
      ),
    );
  }

  /// Returns all registered namespaces.
  @override
  Future<Either<Failure, Set<Namespace>>> getAll() async {
    final urisResult = await storage.getAllUris();
    if (urisResult.isLeft()) {
      return Left(
        urisResult.getLeft().getOrElse(() => StorageFailure('Unknown error')),
      );
    }
    final uris = urisResult.getRight().getOrElse(() => {});
    final Set<Namespace> result = {};
    for (final uriStr in uris) {
      final uri = Uri.parse(uriStr);
      final codesResult = await storage.getIdCodesForUri(uri: uri);
      final codes = codesResult.getOrElse((failure) => {});
      for (final idCode in codes) {
        result.add(Namespace(uri: uri, prefix: idCode));
      }
    }
    return Right(result);
  }

  /// Clears all registrations.
  @override
  Future<Either<Failure, Unit>> clear() async {
    return await storage.clear();
  }
}
