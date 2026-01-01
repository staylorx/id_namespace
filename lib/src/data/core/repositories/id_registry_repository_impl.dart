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

  /// Returns namespace by prefix.
  @override
  Future<Either<Failure, Namespace>> getNamespaceByPrefix({
    required String prefix,
  }) async {
    final allResult = await getAll();
    return allResult.fold((failure) => Left(failure), (allNamespaces) {
      try {
        final namespace = allNamespaces.firstWhere((ns) => ns.prefix == prefix);
        return Right(namespace);
      } catch (e) {
        return Left(NotFoundFailure('Namespace with prefix $prefix not found'));
      }
    });
  }

  /// Returns namespace by code.
  @override
  Future<Either<Failure, Namespace>> getNamespaceByUri({
    required Uri uri,
  }) async {
    final allResult = await getAll();
    return allResult.fold((failure) => Left(failure), (allNamespaces) {
      try {
        final namespace = allNamespaces.firstWhere((ns) => ns.uri == uri);
        return Right(namespace);
      } catch (e) {
        return Left(NotFoundFailure('Namespace with uri $uri not found'));
      }
    });
  }

  /// Returns all registered namespaces.
  @override
  Future<Either<Failure, Set<Namespace>>> getAll() async {
    return await storage.getAll();
  }

  /// Clears all registrations.
  @override
  Future<Either<Failure, Unit>> clear() async {
    return await storage.clear();
  }
}
