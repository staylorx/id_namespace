import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
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

    test('should parse empty content successfully', () async {
      // Given
      final emptyContent = '';
      final url = 'http://example.org/test.ttl';

      // When
      final result = await service.parseRdf(emptyContent, url);

      // Then
      expect(result.isRight(), isTrue);
      final graph = result.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(graph.triples, isEmpty);
    });

    test('should return ParseFailure for malformed Turtle RDF', () async {
      // Given
      final malformedContent = '''
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
<http://example.org/person1> foaf:name "John Doe" invalid syntax here .
''';
      final url = 'http://example.org/test.ttl';

      // When
      final result = await service.parseRdf(malformedContent, url);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<ParseFailure>());
    });

    test('should return ParseFailure for malformed RDF/XML', () async {
      // Given
      final malformedContent = '''
<?xml version="1.0"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:foaf="http://xmlns.com/foaf/0.1/">
  <foaf:Person rdf:about="http://example.org/person1">
    <foaf:name>John Doe</foaf:name>
  <!-- Missing closing tags -->
</rdf:RDF>
''';
      final url = 'http://example.org/test.rdf';

      // When
      final result = await service.parseRdf(malformedContent, url);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<ParseFailure>());
    });

    test('should parse N-Triples content', () async {
      // Given
      final content = '<http://example.org/person1> <http://xmlns.com/foaf/0.1/name> "John Doe" .';
      final url = 'http://example.org/test.nt';

      // When
      final result = await service.parseRdf(content, url);

      // Then
      expect(result.isRight(), isTrue);
      final graph = result.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(graph.triples, isNotEmpty);
    });

    test('should parse JSON-LD content', () async {
      // Given
      final content = '''
{
  "@context": {
    "foaf": "http://xmlns.com/foaf/0.1/"
  },
  "@id": "http://example.org/person1",
  "foaf:name": "John Doe"
}
''';
      final url = 'http://example.org/test.jsonld';

      // When
      final result = await service.parseRdf(content, url);

      // Then
      expect(result.isRight(), isTrue);
      final graph = result.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(graph.triples, isNotEmpty);
    });

    test('should return ParseFailure for malformed JSON-LD', () async {
      // Given
      final malformedContent = '{"invalid": json}';
      final url = 'http://example.org/test.jsonld';

      // When
      final result = await service.parseRdf(malformedContent, url);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<ParseFailure>());
    });

    test('should default to Turtle for unknown extension', () async {
      // Given
      final content = '''
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
<http://example.org/person1> foaf:name "John Doe" .
''';
      final url = 'http://example.org/test.unknown';

      // When
      final result = await service.parseRdf(content, url);

      // Then
      expect(result.isRight(), isTrue);
      final graph = result.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(graph.triples, isNotEmpty);
    });
  });
}
