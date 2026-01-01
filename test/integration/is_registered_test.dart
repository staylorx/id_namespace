import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
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
