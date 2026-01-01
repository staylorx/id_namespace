import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:test/test.dart';

void main() {
  late InMemoryIdStorage storage;
  late Namespace testNamespace1;
  late Namespace testNamespace2;

  setUp(() {
    storage = InMemoryIdStorage();
    testNamespace1 = Namespace(
      uri: Uri.parse('http://example.com/ns1'),
      prefix: 'ns1',
      description: 'Test namespace 1',
    );
    testNamespace2 = Namespace(
      uri: Uri.parse('http://example.com/ns2'),
      prefix: 'ns2',
      description: 'Test namespace 2',
    );
  });

  group('InMemoryIdStorage', () {
    test('should add a namespace successfully', () async {
      // When
      final result = await storage.add(namespace: testNamespace1);

      // Then
      expect(result.isRight(), isTrue);
    });

    test('should return DuplicateIdFailure when adding duplicate namespace', () async {
      // Given
      await storage.add(namespace: testNamespace1);

      // When
      final result = await storage.add(namespace: testNamespace1);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(() => throw Exception('Should be left'));
      expect(failure, isA<DuplicateIdFailure>());
      expect((failure as DuplicateIdFailure).prefix, 'ns1');
    });

    test('should remove a namespace successfully', () async {
      // Given
      await storage.add(namespace: testNamespace1);

      // When
      final result = await storage.remove(namespace: testNamespace1);

      // Then
      expect(result.isRight(), isTrue);
      final containsResult = await storage.contains(namespace: testNamespace1);
      expect(containsResult.getRight().getOrElse(() => false), isFalse);
    });

    test('should return false for contains when namespace not added', () async {
      // When
      final result = await storage.contains(namespace: testNamespace1);

      // Then
      expect(result.isRight(), isTrue);
      expect(result.getRight().getOrElse(() => true), isFalse);
    });

    test('should return true for contains when namespace is added', () async {
      // Given
      await storage.add(namespace: testNamespace1);

      // When
      final result = await storage.contains(namespace: testNamespace1);

      // Then
      expect(result.isRight(), isTrue);
      expect(result.getRight().getOrElse(() => false), isTrue);
    });

    test('should return empty set for getAll when no namespaces added', () async {
      // When
      final result = await storage.getAll();

      // Then
      expect(result.isRight(), isTrue);
      expect(result.getRight().getOrElse(() => {testNamespace1}), isEmpty);
    });

    test('should return all added namespaces for getAll', () async {
      // Given
      await storage.add(namespace: testNamespace1);
      await storage.add(namespace: testNamespace2);

      // When
      final result = await storage.getAll();

      // Then
      expect(result.isRight(), isTrue);
      final namespaces = result.getRight().getOrElse(() => {});
      expect(namespaces.length, 2);
      expect(namespaces, contains(testNamespace1));
      expect(namespaces, contains(testNamespace2));
    });

    test('should clear all namespaces', () async {
      // Given
      await storage.add(namespace: testNamespace1);
      await storage.add(namespace: testNamespace2);

      // When
      final result = await storage.clear();

      // Then
      expect(result.isRight(), isTrue);
      final getAllResult = await storage.getAll();
      expect(getAllResult.getRight().getOrElse(() => {testNamespace1}), isEmpty);
    });
  });
}