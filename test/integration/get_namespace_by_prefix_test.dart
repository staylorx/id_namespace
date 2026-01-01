import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
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
    final retrievedNamespace = result.getRight().getOrElse(
      () => throw Exception('Should be right'),
    );
    expect(retrievedNamespace.uri, namespace.uri);
    expect(retrievedNamespace.prefix, namespace.prefix);
    expect(retrievedNamespace.description, namespace.description);
  });

  test('should return NotFoundFailure for non-existent prefix', () async {
    // When
    final result = await usecase.execute(prefix: 'nonexistent');

    // Then
    expect(result.isLeft(), isTrue);
    final failure = result.getLeft().getOrElse(
      () => throw Exception('Should be left'),
    );
    expect(failure, isA<NotFoundFailure>());
  });

  test('should retrieve namespace by exact prefix match', () async {
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
    final result = await usecase.execute(prefix: 'example');

    // Then
    expect(result.isRight(), isTrue);
    final retrievedNamespace = result.getRight().getOrElse(
      () => throw Exception('Should be right'),
    );
    expect(retrievedNamespace.uri, namespace1.uri);
    expect(retrievedNamespace.prefix, namespace1.prefix);
    expect(retrievedNamespace.description, namespace1.description);
  });
}
