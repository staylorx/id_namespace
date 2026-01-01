import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/services/rdf_parsing_service_impl.dart';
import 'package:id_namespace/src/domain/core/services/rdf_parsing_service.dart';
import 'package:id_namespace/src/utils/failures.dart';
import 'package:test/test.dart';

void main() {
  late RdfParsingService service;

  setUp(() {
    service = RdfParsingServiceImpl();
  });

  group('RdfParsingServiceImpl', () {
    test('should parse Turtle RDF content', () async {
      // Given
      final content = '''
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .

<http://example.org/person1> rdf:type foaf:Person ;
    foaf:name "John Doe" .
''';
      final url = 'http://example.org/test.ttl';

      // When
      final result = await service.parseRdf(content, url);

      // Then
      expect(result.isRight(), isTrue);
      final graph = result.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(graph.triples, isNotEmpty);
    });

    test('should parse RDF/XML content', () async {
      // Given
      final content = '''
<?xml version="1.0"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:foaf="http://xmlns.com/foaf/0.1/">
  <foaf:Person rdf:about="http://example.org/person1">
    <foaf:name>John Doe</foaf:name>
  </foaf:Person>
</rdf:RDF>
''';
      final url = 'http://example.org/test.rdf';

      // When
      final result = await service.parseRdf(content, url);

      // Then
      expect(result.isRight(), isTrue);
      final graph = result.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(graph.triples, isNotEmpty);
    });

    test('should return ParseFailure for invalid RDF content', () async {
      // Given
      final invalidContent = 'This is not RDF content';
      final url = 'http://example.org/test.ttl';

      // When
      final result = await service.parseRdf(invalidContent, url);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<ParseFailure>());
    });
  });
}
