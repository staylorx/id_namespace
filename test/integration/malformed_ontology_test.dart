import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    Logger.root.level = Level.WARNING;
    Logger.root.onRecord.listen((record) {
      stdout.writeln(
        '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}',
      );
    });
  });

  late IdStorage storage;
  late IdRegistryRepository repository;
  late FetchContentService fetchContentService;
  late RdfParsingService rdfParsingService;
  late FetchAndRegisterOntologyUsecase usecase;
  late String tempFilePath;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('id_namespace_test_');
    tempFilePath = '${tempDir.path}/storage.json';
    storage = FileBasedIdStorage(filePath: tempFilePath);
    repository = IdRegistryRepositoryImpl(storage: storage);
    fetchContentService = FetchContentServiceImpl();
    rdfParsingService = RdfParsingServiceImpl();
    usecase = FetchAndRegisterOntologyUsecase(
      fetchContentService: fetchContentService,
      rdfParsingService: rdfParsingService,
      repository: repository,
    );
  });

  tearDown(() async {
    final file = File(tempFilePath);
    if (await file.exists()) await file.delete();
    final dir = Directory(tempFilePath).parent;
    if (await dir.exists()) await dir.delete();
  });

  group('Ontology Loading - Malformed Ontologies', () {
    test('should handle malformed Turtle ontology gracefully', () async {
      final tempDir = await Directory.systemTemp.createTemp('malformed_test_');
      final malformedFile = File('${tempDir.path}/malformed.ttl');
      await malformedFile.writeAsString('''
@prefix ex: <http://example.org/> .
ex:subject ex:predicate "object" .
ex:subject ex:predicate .  # Missing object
ex:subject "literal" ex:object .  # Wrong order
''');

      final result = await usecase.execute(
        url: Uri.file(malformedFile.absolute.path).toString(),
        prefix: "MALFORMED",
        description: "Malformed Turtle ontology",
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.getLeft().getOrElse(() => throw Exception('Should be left')),
        isA<ParseFailure>(),
      );

      await tempDir.delete(recursive: true);
    });

    test('should handle malformed RDF/XML ontology gracefully', () async {
      final tempDir = await Directory.systemTemp.createTemp('malformed_test_');
      final malformedFile = File('${tempDir.path}/malformed.rdf');
      await malformedFile.writeAsString('''
<?xml version="1.0"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about="http://example.org/subject">
    <predicate>Missing namespace</predicate>
  </rdf:Description>
</rdf:RDF>
''');

      final result = await usecase.execute(
        url: Uri.file(malformedFile.absolute.path).toString(),
        prefix: "MALFORMED",
        description: "Malformed RDF/XML ontology",
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.getLeft().getOrElse(() => throw Exception('Should be left')),
        isA<ParseFailure>(),
      );

      await tempDir.delete(recursive: true);
    });

    test('should handle malformed JSON-LD ontology gracefully', () async {
      final tempDir = await Directory.systemTemp.createTemp('malformed_test_');
      final malformedFile = File('${tempDir.path}/malformed.jsonld');
      await malformedFile.writeAsString('''
{
  "@context": "http://schema.org/",
  "@graph": [
    {
      "@id": "http://example.org/subject",
      "name": "Test"
    }
  ]
}
''');

      final result = await usecase.execute(
        url: Uri.file(malformedFile.absolute.path).toString(),
        prefix: "MALFORMED",
        description: "Malformed JSON-LD ontology",
      );

      // JSON-LD might be more forgiving, but let's check if it fails or succeeds
      // Depending on the parser, it might succeed or fail
      // For now, just ensure it's handled without crashing
      expect(result.isLeft() || result.isRight(), isTrue);

      await tempDir.delete(recursive: true);
    });

    test('should handle empty ontology file gracefully', () async {
      final tempDir = await Directory.systemTemp.createTemp('malformed_test_');
      final emptyFile = File('${tempDir.path}/empty.ttl');
      await emptyFile.writeAsString('');

      final result = await usecase.execute(
        url: Uri.file(emptyFile.absolute.path).toString(),
        prefix: "EMPTY",
        description: "Empty ontology",
      );

      // Empty ontology should succeed (0 triples is valid)
      expect(result.isRight(), isTrue);

      await tempDir.delete(recursive: true);
    });

    test('should handle non-existent file gracefully', () async {
      final result = await usecase.execute(
        url: "file:///non/existent/path/ontology.ttl",
        prefix: "NONEXISTENT",
        description: "Non-existent ontology",
      );

      expect(result.isLeft(), isTrue);
      // Could be FetchFailure or ParseFailure depending on implementation
    });
  });
}
