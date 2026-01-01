import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockIdStorage extends Mock implements IdStorage {}

void main() {
  late MockIdStorage mockStorage;
  late CachedIdStorage cachedStorage;
  late InMemoryIdStorage realStorage;
  late CachedIdStorage cachedRealStorage;
  late Namespace testNamespace1;
  late Namespace testNamespace2;

  setUp(() {
    mockStorage = MockIdStorage();
    cachedStorage = CachedIdStorage(storage: mockStorage);
    realStorage = InMemoryIdStorage();
    cachedRealStorage = CachedIdStorage(storage: realStorage);
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

  group('CachedIdStorage', () {
    test('should add namespace and update cache on success', () async {
      // Given
      when(
        () => mockStorage.add(namespace: testNamespace1),
      ).thenAnswer((_) async => Right(unit));

      // When
      final result = await cachedStorage.add(namespace: testNamespace1);

      // Then
      expect(result.isRight(), isTrue);
      verify(() => mockStorage.add(namespace: testNamespace1)).called(1);
    });

    test(
      'should return failure when underlying storage fails to add',
      () async {
        // Given
        final failure = StorageFailure('Add failed');
        when(
          () => mockStorage.add(namespace: testNamespace1),
        ).thenAnswer((_) async => Left(failure));

        // When
        final result = await cachedStorage.add(namespace: testNamespace1);

        // Then
        expect(result.isLeft(), isTrue);
        expect(result.getLeft().getOrElse(() => StorageFailure('')), failure);
        verify(() => mockStorage.add(namespace: testNamespace1)).called(1);
      },
    );

    test('should remove namespace and update cache on success', () async {
      // Given
      when(
        () => mockStorage.remove(namespace: testNamespace1),
      ).thenAnswer((_) async => Right(unit));

      // When
      final result = await cachedStorage.remove(namespace: testNamespace1);

      // Then
      expect(result.isRight(), isTrue);
      verify(() => mockStorage.remove(namespace: testNamespace1)).called(1);
    });

    test(
      'should return failure when underlying storage fails to remove',
      () async {
        // Given
        final failure = StorageFailure('Remove failed');
        when(
          () => mockStorage.remove(namespace: testNamespace1),
        ).thenAnswer((_) async => Left(failure));

        // When
        final result = await cachedStorage.remove(namespace: testNamespace1);

        // Then
        expect(result.isLeft(), isTrue);
        expect(result.getLeft().getOrElse(() => StorageFailure('')), failure);
        verify(() => mockStorage.remove(namespace: testNamespace1)).called(1);
      },
    );

    test(
      'should check cache first for contains when cache is loaded',
      () async {
        // Given
        await cachedRealStorage.add(
          namespace: testNamespace1,
        ); // This loads cache

        // When
        final result = await cachedRealStorage.contains(
          namespace: testNamespace1,
        );

        // Then
        expect(result.isRight(), isTrue);
        expect(result.getRight().getOrElse(() => false), isTrue);
      },
    );

    test(
      'should delegate to storage for contains when cache not loaded',
      () async {
        // Given
        when(
          () => mockStorage.contains(namespace: testNamespace1),
        ).thenAnswer((_) async => Right(true));

        // When
        final result = await cachedStorage.contains(namespace: testNamespace1);

        // Then
        expect(result.isRight(), isTrue);
        expect(result.getRight().getOrElse(() => false), isTrue);
        verify(() => mockStorage.contains(namespace: testNamespace1)).called(1);
      },
    );

    test('should return cached data for getAll when cache is loaded', () async {
      // Given
      final namespaces = {testNamespace1, testNamespace2};
      await cachedRealStorage.add(namespace: testNamespace1);
      await cachedRealStorage.add(namespace: testNamespace2);

      // When
      final result = await cachedRealStorage.getAll();

      // Then
      expect(result.isRight(), isTrue);
      expect(result.getRight().getOrElse(() => {}), containsAll(namespaces));
    });

    test(
      'should fetch from storage and cache for getAll when cache not loaded',
      () async {
        // Given
        final namespaces = {testNamespace1, testNamespace2};
        when(
          () => mockStorage.getAll(),
        ).thenAnswer((_) async => Right(namespaces));

        // When
        final result = await cachedStorage.getAll();

        // Then
        expect(result.isRight(), isTrue);
        expect(result.getRight().getOrElse(() => {}), containsAll(namespaces));
        verify(() => mockStorage.getAll()).called(1);

        // Subsequent call should use cache
        final result2 = await cachedStorage.getAll();
        expect(result2.getRight().getOrElse(() => {}), containsAll(namespaces));
        verifyNoMoreInteractions(mockStorage);
      },
    );

    test('should return failure for getAll when storage fails', () async {
      // Given
      final failure = StorageFailure('Get all failed');
      when(() => mockStorage.getAll()).thenAnswer((_) async => Left(failure));

      // When
      final result = await cachedStorage.getAll();

      // Then
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().getOrElse(() => StorageFailure('')), failure);
      verify(() => mockStorage.getAll()).called(1);
    });

    test('should clear storage and cache on success', () async {
      // Given
      when(() => mockStorage.clear()).thenAnswer((_) async => Right(unit));
      await cachedRealStorage.add(namespace: testNamespace1); // Load cache

      // When
      final result = await cachedRealStorage.clear();

      // Then
      expect(result.isRight(), isTrue);

      // Cache should be cleared
      final containsResult = await cachedRealStorage.contains(
        namespace: testNamespace1,
      );
      expect(containsResult.getRight().getOrElse(() => true), isFalse);
    });

    test(
      'should return failure when underlying storage fails to clear',
      () async {
        // Given
        final failure = StorageFailure('Clear failed');
        when(() => mockStorage.clear()).thenAnswer((_) async => Left(failure));

        // When
        final result = await cachedStorage.clear();

        // Then
        expect(result.isLeft(), isTrue);
        expect(result.getLeft().getOrElse(() => StorageFailure('')), failure);
        verify(() => mockStorage.clear()).called(1);
      },
    );
  });
}
