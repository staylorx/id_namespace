import 'package:fpdart/fpdart.dart';

import '../../../domain/core/failures.dart';
import '../../../domain/core/repositories/id_registry_repository.dart';
import '../../../domain/core/value_objects/namespace.dart';
import '../../../domain/storage/repositories/storage.dart';

class IdRegistryRepositoryImpl implements IdRegistryRepository {
  final IdStorage storage;

  IdRegistryRepositoryImpl(this.storage);

  @override
  Future<Either<Failure, Unit>> add({required Namespace namespace}) async {
    return await storage.add(namespace: namespace);
  }

  @override
  Future<Either<Failure, Unit>> remove({required Namespace namespace}) async {
    return await storage.remove(namespace: namespace);
  }

  @override
  Future<Either<Failure, bool>> isRegistered({required Namespace namespace}) async {
    return await storage.contains(namespace: namespace);
  }

  @override
  Future<Either<Failure, Set<Namespace>>> getNamespaceByPrefix({required String prefix}) async {
    final allResult = await getAll();
    return allResult.fold(
      (failure) => Left(failure),
      (allNamespaces) => Right(allNamespaces.where((namespace) => namespace.prefix.startsWith(prefix)).toSet()),
    );
  }

  @override
  Future<Either<Failure, Set<Namespace>>> getNamespaceByCode({required String code}) async {
    final allResult = await getAll();
    return allResult.fold(
      (failure) => Left(failure),
      (allNamespaces) => Right(allNamespaces.where((namespace) => namespace.prefix == code).toSet()),
    );
  }

  @override
  Future<Either<Failure, Set<Namespace>>> getAll() async {
    final urisResult = await storage.getAllUris();
    return urisResult.fold(
      (failure) => Left(failure),
      (uris) async {
        final Set<Namespace> result = {};
        for (final uriStr in uris) {
          final uri = Uri.parse(uriStr);
          final codesResult = await storage.getIdCodesForUri(uri);
          final codes = codesResult.getOrElse((failure) => {});
          for (final idCode in codes) {
            result.add(Namespace(uri: uri, prefix: idCode));
          }
        }
        return Right(result);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    return await storage.clear();
  }
}
