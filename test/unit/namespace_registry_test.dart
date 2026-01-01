import 'package:id_namespace/id_namespace.dart';
import 'package:test/test.dart';

void main() {
  late Namespace testNamespace1;
  late Namespace testNamespace2;

  setUp(() {
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

  group('NamespaceRegistry', () {
    test('should create registry with given map', () {
      // Given
      final registryMap = {'ns1': testNamespace1, 'ns2': testNamespace2};

      // When
      final registry = NamespaceRegistry(registry: registryMap);

      // Then
      expect(registry.registry, equals(registryMap));
    });

    test('should be equal when registries have same content', () {
      // Given
      final registry1 = NamespaceRegistry(registry: {'ns1': testNamespace1});
      final registry2 = NamespaceRegistry(registry: {'ns1': testNamespace1});

      // Then
      expect(registry1, equals(registry2));
    });

    test('should not be equal when registries have different content', () {
      // Given
      final registry1 = NamespaceRegistry(registry: {'ns1': testNamespace1});
      final registry2 = NamespaceRegistry(registry: {'ns2': testNamespace2});

      // Then
      expect(registry1, isNot(equals(registry2)));
    });

    test('should not be equal when registries have different sizes', () {
      // Given
      final registry1 = NamespaceRegistry(registry: {'ns1': testNamespace1});
      final registry2 = NamespaceRegistry(
        registry: {'ns1': testNamespace1, 'ns2': testNamespace2},
      );

      // Then
      expect(registry1, isNot(equals(registry2)));
    });

    test('should have correct props for Equatable', () {
      // Given
      final registryMap = {'ns1': testNamespace1};
      final registry = NamespaceRegistry(registry: registryMap);

      // Then
      expect(registry.props, [registryMap]);
    });
  });
}
