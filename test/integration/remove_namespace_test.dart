import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late RemoveNamespaceUsecase usecase;

  setUp(() {
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    usecase = RemoveNamespaceUsecase(repository: repository);
  });

  test('should remove a namespace successfully', () async {
    // Given
    final namespace = Namespace(
      uri: Uri.parse('http://example.com/ns#'),
      prefix: 'ex',
      description: 'Example namespace',
    );

    // Add the namespace first
    final addResult = await repository.add(namespace: namespace);
    expect(addResult.isRight(), isTrue);

    // Verify it's registered
    final isRegisteredBefore = await repository.isRegistered(
      namespace: namespace,
    );
    expect(isRegisteredBefore.isRight(), isTrue);
    expect(isRegisteredBefore.getRight().getOrElse(() => false), isTrue);

    // When
    final result = await usecase.execute(namespace: namespace);

    // Then
    expect(result.isRight(), isTrue);

    // Verify the namespace is no longer registered
    final isRegisteredAfter = await repository.isRegistered(
      namespace: namespace,
    );
    expect(isRegisteredAfter.isRight(), isTrue);
    expect(isRegisteredAfter.getRight().getOrElse(() => true), isFalse);

    // Verify it doesn't appear in getAll
    final getAllResult = await repository.getAll();
    expect(getAllResult.isRight(), isTrue);
    final namespaces = getAllResult.getRight().getOrElse(() => {});
    expect(namespaces.isEmpty, isTrue);
  });

  test(
    'should succeed when attempting to remove non-existent namespace',
    () async {
      // Given
      final namespace = Namespace(
        uri: Uri.parse('http://example.com/ns#'),
        prefix: 'ex',
        description: 'Example namespace',
      );

      // Verify it's not registered initially
      final isRegisteredBefore = await repository.isRegistered(
        namespace: namespace,
      );
      expect(isRegisteredBefore.isRight(), isTrue);
      expect(isRegisteredBefore.getRight().getOrElse(() => true), isFalse);

      // When
      final result = await usecase.execute(namespace: namespace);

      // Then should succeed (idempotent operation)
      expect(result.isRight(), isTrue);
    },
  );
}
