import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/in_memory_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/get_namespace_by_prefix_usecase.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late GetNamespaceByPrefixUsecase usecase;

  setUp(() {
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    usecase = GetNamespaceByPrefixUsecase(repository: repository);
  });

  test('should retrieve namespace successfully by exact prefix', () async {
    // Given
    final namespace = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'ex',
      description: 'Example namespace',
    );

    // Add the namespace
    final addResult = await repository.add(namespace: namespace);
    expect(addResult.isRight(), isTrue);

    // When
    final result = await usecase.execute(prefix: 'ex');

    // Then
    expect(result.isRight(), isTrue);
    final namespaces = result.getRight().getOrElse(() => {});
    expect(namespaces.length, 1);
    expect(namespaces.first.uri, namespace.uri);
    expect(namespaces.first.prefix, namespace.prefix);
    expect(namespaces.first.description, namespace.description);
  });

  test('should return empty set for non-existent prefix', () async {
    // When
    final result = await usecase.execute(prefix: 'nonexistent');

    // Then
    expect(result.isRight(), isTrue);
    final namespaces = result.getRight().getOrElse(() => {});
    expect(namespaces.isEmpty, isTrue);
  });

  test('should retrieve namespaces that start with the prefix', () async {
    // Given
    final namespace1 = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'example',
      description: 'Example namespace',
    );
    final namespace2 = Namespace(
      uri: Uri.parse('http://other.com/ns#'),
      prefix: 'exam',
      description: 'Other namespace',
    );

    // Add namespaces
    await repository.add(namespace: namespace1);
    await repository.add(namespace: namespace2);

    // When
    final result = await usecase.execute(prefix: 'ex');

    // Then
    expect(result.isRight(), isTrue);
    final namespaces = result.getRight().getOrElse(() => {});
    expect(namespaces.length, 2);
    final prefixes = namespaces.map((n) => n.prefix).toSet();
    expect(prefixes, {'example', 'exam'});
  });
}
