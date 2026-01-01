import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/in_memory_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/add_namespace_usecase.dart';
import 'package:id_namespace/src/domain/core/usecases/get_all_namespaces_usecase.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late AddNamespaceUsecase addUsecase;
  late GetAllNamespacesUsecase getAllUsecase;

  setUp(() {
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    addUsecase = AddNamespaceUsecase(repository: repository);
    getAllUsecase = GetAllNamespacesUsecase(repository: repository);
  });

  test('should return empty set when no namespaces are registered', () async {
    // When
    final result = await getAllUsecase.execute();

    // Then
    expect(result.isRight(), isTrue);
    final namespaces = result.getRight().getOrElse(() => {});
    expect(namespaces, isEmpty);
  });

  test('should return all registered namespaces', () async {
    // Given
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

    // Add namespaces
    await addUsecase.execute(namespace: namespace1);
    await addUsecase.execute(namespace: namespace2);

    // When
    final result = await getAllUsecase.execute();

    // Then
    expect(result.isRight(), isTrue);
    final namespaces = result.getRight().getOrElse(() => {});
    expect(namespaces.length, 2);
    expect(namespaces.map((n) => n.uri), contains(namespace1.uri));
    expect(namespaces.map((n) => n.uri), contains(namespace2.uri));
    expect(namespaces.map((n) => n.prefix), contains(namespace1.prefix));
    expect(namespaces.map((n) => n.prefix), contains(namespace2.prefix));
  });
}
