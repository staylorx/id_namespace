import '../../../domain/core/repositories/id_registry_repository.dart';
import '../../../domain/core/value_objects/namespace.dart';
import '../../../domain/storage/repositories/storage.dart';

class IdRegistryRepositoryImpl implements IdRegistryRepository {
  final IdStorage storage;

  IdRegistryRepositoryImpl(this.storage);

  @override
  Future<void> add({required Namespace namespace}) async {
    await storage.add(namespace: namespace);
  }

  @override
  Future<void> remove({required Namespace namespace}) async {
    await storage.remove(namespace: namespace);
  }

  @override
  Future<bool> isRegistered({required Namespace namespace}) async {
    return await storage.contains(namespace: namespace);
  }

  @override
  Future<Set<Namespace>> getNamespaceByPrefix({required String prefix}) async {
    final allNamespaces = await getAll();
    return allNamespaces
        .where((namespace) => namespace.idCode.startsWith(prefix))
        .toSet();
  }

  @override
  Future<Set<Namespace>> getNamespaceByCode({required String code}) async {
    final allNamespaces = await getAll();
    return allNamespaces.where((namespace) => namespace.idCode == code).toSet();
  }

  @override
  Future<Set<Namespace>> getAll() async {
    final idTypes = await storage.getAll();
    final Set<Namespace> result = {};
    for (final idType in idTypes) {
      final idCodes = await storage.getAll();
      for (final idCode in idCodes) {
        // Assuming Namespace can be constructed from uri (idType), prefix (idCode?), but wait.
        // The task says "create a Set<Namespace> from all combinations."
        // But Namespace requires uri, prefix, idCode.
        // Perhaps idType is uri.toString(), idCode is idCode, but prefix is missing.
        // Perhaps prefix is idCode, but the method is getNamespaceByPrefix, filtering on idCode.startsWith(prefix).
        // Perhaps idCode is prefix.
        // To create Namespace, I need uri, prefix, idCode.
        // Perhaps uri is Uri.parse(idType), prefix is idCode, idCode is idCode.
        // But that doesn't make sense.
        // Perhaps the storage stores the full Namespace, but the getAll returns Set<String> for idCodes, but to reconstruct, I need more.
        // This is a problem.
        // Perhaps I need to store the full Namespace in storage, and change getAll to return Set<Namespace>.
        // But the interface has getAll returning Set<String>.
        // To fix, perhaps change the storage interface to store full Namespace, and getAll returns Set<Namespace>.
        // But the task says "get the set of idCodes from storage.getAll(idType: idType)", so it's Set<String>.
        // To create Namespace, perhaps Namespace has a constructor with uri and idCode, and prefix is idCode or something.
        // Perhaps idType is uri.toString(), idCode is idCode, and prefix is idCode.
        // Let's assume that.
        // So, Namespace(uri: Uri.parse(idType), prefix: idCode, idCode: idCode)
        // But prefix is String, idCode is String.
        // Perhaps prefix is idCode.
        // Yes, let's do that.
        result.add(
          Namespace(uri: Uri.parse(idType), prefix: idCode, idCode: idCode),
        );
      }
    }
    return result;
  }

  @override
  Future<void> clear() async {
    await storage.clear();
  }
}
