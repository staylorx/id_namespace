import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/in_memory_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/add_namespace_usecase.dart';
import 'package:id_namespace/src/domain/core/usecases/get_namespace_by_code_usecase.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:id_namespace/src/utils/failures.dart';
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
    final retrievedNamespace = result.getRight().getOrElse(
      () => throw Exception('Should be right'),
    );
    expect(retrievedNamespace.uri, namespace.uri);
    expect(retrievedNamespace.prefix, namespace.prefix);
    expect(retrievedNamespace.description, namespace.description);
  });

  test('should return NotFoundFailure when code not found', () async {
    // When
    final result = await getUsecase.execute(code: 'nonexistent');

    // Then
    expect(result.isLeft(), isTrue);
    final failure = result.getLeft().getOrElse(
      () => throw Exception('Should be left'),
    );
    expect(failure, isA<NotFoundFailure>());
  });
}
