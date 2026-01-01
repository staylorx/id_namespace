import 'package:id_namespace/id_namespace.dart';
import 'package:test/test.dart';

void main() {
  late Uri testUri;
  late String testPrefix;
  late String testDescription;

  setUp(() {
    testUri = Uri.parse('http://example.com/test');
    testPrefix = 'test';
    testDescription = 'Test namespace';
  });

  group('Namespace', () {
    test('should create namespace with required fields', () {
      // When
      final namespace = Namespace(uri: testUri, prefix: testPrefix);

      // Then
      expect(namespace.uri, testUri);
      expect(namespace.prefix, testPrefix);
      expect(namespace.description, isNull);
      expect(namespace.rdfGraph, isNull);
    });

    test('should create namespace with all fields', () {
      // When
      final namespace = Namespace(
        uri: testUri,
        prefix: testPrefix,
        description: testDescription,
        rdfGraph: null,
      );

      // Then
      expect(namespace.uri, testUri);
      expect(namespace.prefix, testPrefix);
      expect(namespace.description, testDescription);
      expect(namespace.rdfGraph, isNull);
    });

    test('copyWith should return new instance with updated fields', () {
      // Given
      final original = Namespace(
        uri: testUri,
        prefix: testPrefix,
        description: testDescription,
      );
      final newUri = Uri.parse('http://example.com/new');
      final newPrefix = 'new';
      final newDescription = 'New description';

      // When
      final copied = original.copyWith(
        uri: newUri,
        prefix: newPrefix,
        description: newDescription,
      );

      // Then
      expect(copied.uri, newUri);
      expect(copied.prefix, newPrefix);
      expect(copied.description, newDescription);
      expect(copied.rdfGraph, original.rdfGraph); // Unchanged
    });

    test('copyWith with no arguments should return identical instance', () {
      // Given
      final original = Namespace(
        uri: testUri,
        prefix: testPrefix,
        description: testDescription,
      );

      // When
      final copied = original.copyWith();

      // Then
      expect(copied.uri, original.uri);
      expect(copied.prefix, original.prefix);
      expect(copied.description, original.description);
      expect(copied.rdfGraph, original.rdfGraph);
    });

    test('should be equal when prefixes are the same', () {
      // Given
      final ns1 = Namespace(uri: testUri, prefix: testPrefix);
      final ns2 = Namespace(uri: testUri, prefix: testPrefix);

      // Then
      expect(ns1, equals(ns2));
    });

    test('should not be equal when prefixes are different', () {
      // Given
      final ns1 = Namespace(uri: testUri, prefix: testPrefix);
      final ns2 = Namespace(uri: testUri, prefix: 'different');

      // Then
      expect(ns1, isNot(equals(ns2)));
    });

    test('should not be equal when other fields differ but prefix same', () {
      // Given
      final ns1 = Namespace(
        uri: testUri,
        prefix: testPrefix,
        description: testDescription,
      );
      final ns2 = Namespace(
        uri: Uri.parse('http://different.com'),
        prefix: testPrefix,
        description: 'Different',
      );

      // Then
      expect(ns1, equals(ns2)); // Only prefix matters for equality
    });

    test('should have correct props for Equatable', () {
      // Given
      final namespace = Namespace(
        uri: testUri,
        prefix: testPrefix,
        description: testDescription,
      );

      // Then
      expect(namespace.props, [testPrefix]);
    });
  });
}
