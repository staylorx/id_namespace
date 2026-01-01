import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String testFilePath;
  late FileBasedIdStorage storage;
  late Namespace testNamespace1;
  late Namespace testNamespace2;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('file_based_storage_test');
    testFilePath = path.join(tempDir.path, 'test_storage.json');
    storage = FileBasedIdStorage(filePath: testFilePath);
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

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('FileBasedIdStorage', () {
    test('should add a namespace successfully', () async {
      // When
      final result = await storage.add(namespace: testNamespace1);

      // Then
      expect(result.isRight(), isTrue);
      final file = File(testFilePath);
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content, contains('ns1'));
    });

    test(
      'should return DuplicateIdFailure when adding duplicate namespace',
      () async {
        // Given
        await storage.add(namespace: testNamespace1);

        // When
        final result = await storage.add(namespace: testNamespace1);

        // Then
        expect(result.isLeft(), isTrue);
        final failure = result.getLeft().getOrElse(
          () => throw Exception('Should be left'),
        );
        expect(failure, isA<DuplicateIdFailure>());
        expect((failure as DuplicateIdFailure).prefix, 'ns1');
      },
    );

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

    test(
      'should return empty set for getAll when no namespaces added',
      () async {
        // When
        final result = await storage.getAll();

        // Then
        expect(result.isRight(), isTrue);
        expect(result.getRight().getOrElse(() => {testNamespace1}), isEmpty);
      },
    );

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
      expect(
        getAllResult.getRight().getOrElse(() => {testNamespace1}),
        isEmpty,
      );
    });

    test('should load existing data from file', () async {
      // Given
      final file = File(testFilePath);
      final jsonData = {
        'namespaces': [
          {
            'uri': 'http://example.com/preloaded',
            'prefix': 'pre',
            'description': 'Preloaded namespace',
          },
        ],
      };
      file.writeAsStringSync(json.encode(jsonData));

      // When
      final result = await storage.getAll();

      // Then
      expect(result.isRight(), isTrue);
      final namespaces = result.getRight().getOrElse(() => {});
      expect(namespaces.length, 1);
      final ns = namespaces.first;
      expect(ns.prefix, 'pre');
      expect(ns.uri.toString(), 'http://example.com/preloaded');
    });

    test('should return StorageFailure for invalid JSON in file', () async {
      // Given
      final file = File(testFilePath);
      file.writeAsStringSync('invalid json');

      // When
      final result = await storage.getAll();

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<StorageFailure>());
    });

    test('should handle file not existing gracefully', () async {
      // File doesn't exist, should return empty

      // When
      final result = await storage.getAll();

      // Then
      expect(result.isRight(), isTrue);
      expect(result.getRight().getOrElse(() => {testNamespace1}), isEmpty);
    });

    // Edge case: save fails (e.g., no write permission)
    // On Windows, hard to simulate, so skip or use a different approach.
    // For now, assume normal file system works.
  });
}
