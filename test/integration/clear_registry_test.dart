import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/in_memory_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/add_namespace_usecase.dart';
import 'package:id_namespace/src/domain/core/usecases/clear_registry_usecase.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late AddNamespaceUsecase addUsecase;
  late ClearRegistryUsecase clearUsecase;

  setUp(() {
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    addUsecase = AddNamespaceUsecase(repository: repository);
    clearUsecase = ClearRegistryUsecase(repository: repository);
  });

  test('should clear all namespaces successfully', () async {
    // Given: Add some namespaces
    final namespace1 = Namespace(
      uri: Uri.parse('http://example.com/ns1#'),
      prefix: 'ex1',
      description: 'Example namespace 1',
    );
    final namespace2 = Namespace(
      uri: Uri.parse('http://example.com/ns2#'),
      prefix: 'ex2',
      description: 'Example namespace 2',
    );

    await addUsecase.execute(namespace: namespace1);
    await addUsecase.execute(namespace: namespace2);

    // Verify they are added
    final getAllBefore = await repository.getAll();
    expect(getAllBefore.isRight(), isTrue);
    expect(getAllBefore.getRight().getOrElse(() => {}).length, 2);

    // When: Clear the registry
    final result = await clearUsecase.execute();

    // Then: Should succeed
    expect(result.isRight(), isTrue);

    // Verify the registry is empty
    final getAllAfter = await repository.getAll();
    expect(getAllAfter.isRight(), isTrue);
    expect(getAllAfter.getRight().getOrElse(() => {}).length, 0);

    // Verify namespaces are no longer registered
    final isRegistered1 = await repository.isRegistered(namespace: namespace1);
    expect(isRegistered1.isRight(), isTrue);
    expect(isRegistered1.getRight().getOrElse(() => false), isFalse);

    final isRegistered2 = await repository.isRegistered(namespace: namespace2);
    expect(isRegistered2.isRight(), isTrue);
    expect(isRegistered2.getRight().getOrElse(() => false), isFalse);
  });

  test('should succeed when registry is already empty', () async {
    // Given: No namespaces added

    // When: Clear the registry
    final result = await clearUsecase.execute();

    // Then: Should succeed
    expect(result.isRight(), isTrue);

    // Verify the registry remains empty
    final getAll = await repository.getAll();
    expect(getAll.isRight(), isTrue);
    expect(getAll.getRight().getOrElse(() => {}).length, 0);
  });
}
