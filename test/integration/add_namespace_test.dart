import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/in_memory_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/add_namespace_usecase.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late AddNamespaceUsecase usecase;

  setUp(() {
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    usecase = AddNamespaceUsecase(repository: repository);
  });

  test('should add a namespace successfully', () async {
    // Given
    final namespace = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'ex',
      description: 'Example namespace',
    );

    // When
    final result = await usecase.execute(namespace: namespace);

    // Then
    expect(result.isRight(), isTrue);

    // Verify the namespace is registered
    final isRegisteredResult = await repository.isRegistered(
      namespace: namespace,
    );
    expect(isRegisteredResult.isRight(), isTrue);
    expect(isRegisteredResult.getRight().getOrElse(() => false), isTrue);

    // Verify it appears in getAll
    final getAllResult = await repository.getAll();
    expect(getAllResult.isRight(), isTrue);
    final namespaces = getAllResult.getRight().getOrElse(() => {});
    expect(namespaces.length, 1);
    expect(namespaces.first.uri, namespace.uri);
    expect(namespaces.first.prefix, namespace.prefix);
    expect(namespaces.first.description, namespace.description);
  });

  test('should fail to add duplicate namespace', () async {
    // Given
    final namespace = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'ex',
      description: 'Example namespace',
    );

    // Add once
    final firstResult = await usecase.execute(namespace: namespace);
    expect(firstResult.isRight(), isTrue);

    // When adding again
    final secondResult = await usecase.execute(namespace: namespace);

    // Then should fail (assuming storage prevents duplicates)
    expect(secondResult.isLeft(), isTrue);
  });

  test('should fail to add duplicate prefix', () async {
    // Given
    final namespace1 = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'ex',
      description: 'Example namespace',
    );
    final namespace2 = Namespace(
      uri: Uri.parse('http://example.edu/ns#'),
      prefix: 'ex',
      description: 'Different uri',
    );

    // Add once
    final firstResult = await usecase.execute(namespace: namespace1);
    expect(firstResult.isRight(), isTrue);

    // When adding again
    final secondResult = await usecase.execute(namespace: namespace2);

    // Then should fail (assuming storage prevents duplicates)
    expect(secondResult.isLeft(), isTrue);
  });

  test('should be okay to add duplicate uri', () async {
    // Given
    final namespace1 = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'ex',
      description: 'Example namespace',
    );
    final namespace2 = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'exe',
      description: 'Different prefix',
    );

    // Add once
    final firstResult = await usecase.execute(namespace: namespace1);
    expect(firstResult.isRight(), isTrue);

    // When adding again
    final secondResult = await usecase.execute(namespace: namespace2);

    // Then should succeed (Uris can be duplicated provided prefixes differ)
    expect(secondResult.isRight(), isTrue);
  });
}
