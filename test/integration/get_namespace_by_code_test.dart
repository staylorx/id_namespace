import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/in_memory_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/add_namespace_usecase.dart';
import 'package:id_namespace/src/domain/core/usecases/get_namespace_by_code_usecase.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late AddNamespaceUsecase addUsecase;
  late GetNamespaceByCodeUsecase getUsecase;

  setUp(() {
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    addUsecase = AddNamespaceUsecase(repository: repository);
    getUsecase = GetNamespaceByCodeUsecase(repository: repository);
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
    final result = await getUsecase.execute(code: 'ex');

    // Then
    expect(result.isRight(), isTrue);
    final namespaces = result.getRight().getOrElse(() => {});
    expect(namespaces.length, 1);
    expect(namespaces.first.uri, namespace.uri);
    expect(namespaces.first.prefix, namespace.prefix);
    expect(namespaces.first.description, namespace.description);
  });

  test('should return empty set when code not found', () async {
    // When
    final result = await getUsecase.execute(code: 'nonexistent');

    // Then
    expect(result.isRight(), isTrue);
    final namespaces = result.getRight().getOrElse(() => {});
    expect(namespaces.isEmpty, isTrue);
  });
}
