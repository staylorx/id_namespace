import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late AddNamespaceUsecase addUsecase;
  late GetNamespaceByUriUsecase getUsecase;

  setUp(() {
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    addUsecase = AddNamespaceUsecase(repository: repository);
    getUsecase = GetNamespaceByUriUsecase(repository: repository);
  });

  test('should retrieve namespace by code successfully', () async {
    // Given
    final namespace = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'ex',
      description: 'Example namespace',
    );

    // Add the namespace
    final addResult = await addUsecase.execute(namespace: namespace);
    expect(addResult.isRight(), isTrue);

    // When
    final result = await getUsecase.execute(
      uri: Uri.parse('http://example.com/ns#'),
    );

    // Then
    expect(result.isRight(), isTrue);
    final retrievedNamespace = result.getRight().getOrElse(
      () => throw Exception('Should be right'),
    );
    expect(retrievedNamespace.uri, namespace.uri);
    expect(retrievedNamespace.prefix, namespace.prefix);
    expect(retrievedNamespace.description, namespace.description);
  });

  test('should return NotFoundFailure when code not found', () async {
    // When
    final result = await getUsecase.execute(uri: Uri.parse('nonexistent'));

    // Then
    expect(result.isLeft(), isTrue);
    final failure = result.getLeft().getOrElse(
      () => throw Exception('Should be left'),
    );
    expect(failure, isA<NotFoundFailure>());
  });
}
