import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/in_memory_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/add_namespace_usecase.dart';
import 'package:id_namespace/src/domain/core/usecases/is_registered_usecase.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late AddNamespaceUsecase addNamespaceUsecase;
  late IsRegisteredUsecase isRegisteredUsecase;

  setUp(() {
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    addNamespaceUsecase = AddNamespaceUsecase(repository: repository);
    isRegisteredUsecase = IsRegisteredUsecase(repository: repository);
  });

  test('should return true when namespace is registered', () async {
    // Given
    final namespace = Namespace(
      uri: Uri.parse('http://example.com/test'),
      prefix: 'test',
      description: 'Test namespace',
    );

    // When
    await addNamespaceUsecase.execute(namespace: namespace);
    final result = await isRegisteredUsecase.execute(namespace: namespace);

    // Then
    expect(result.isRight(), isTrue);
    expect(result.getRight().getOrElse(() => false), isTrue);
  });

  test('should return false when namespace is not registered', () async {
    // Given
    final namespace = Namespace(
      uri: Uri.parse('http://example.com/unregistered'),
      prefix: 'unregistered',
      description: 'Unregistered namespace',
    );

    // When
    final result = await isRegisteredUsecase.execute(namespace: namespace);

    // Then
    expect(result.isRight(), isTrue);
    expect(result.getRight().getOrElse(() => true), isFalse);
  });
}
