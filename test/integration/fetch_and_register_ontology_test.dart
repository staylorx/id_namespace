import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:logging/logging.dart';
import 'package:rdf_xml/rdf_xml.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print(
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

  test('should fetch and register FOAF ontology by file', () async {
    final file = File("test/assets/ontologies/rdf.rdf");

    // Given
    final ontology = {
      "prefix": "RDF",
      "description": "Resource Description Framework",
      "downloadURL": Uri.file(file.absolute.path).toString(),
    };

    // When
    final result = await usecase.execute(
      url: ontology['downloadURL']!,
      prefix: ontology['prefix']!,
      description: ontology['description'],
    );

    // Then
    expect(result.isRight(), isTrue);

    // Verify the ontology is registered
    final getResult = await repository.getNamespaceByUri(
      uri: Uri.parse(ontology['downloadURL']!),
    );
    expect(getResult.isRight(), isTrue);
    final namespace = getResult.getRight().getOrElse(
      () => throw Exception('Should be right'),
    );
    expect(namespace.prefix, ontology['prefix']);
    expect(namespace.uri.toString(), ontology['downloadURL']);

    // Verify the RdfGraph is properly stored and retrieved
    expect(namespace.rdfGraph, isNotNull);
    expect(namespace.rdfGraph!.triples, isNotEmpty);

    // Verify the RdfGraph matches the expected parsed content from the ontology file
    final filePath = ontology['downloadURL']!.replaceFirst('file:///', '');
    final content = await File(filePath).readAsString();
    final expectedGraph = rdfxml.decode(content);

    final actualLength = namespace.rdfGraph!.triples.length;
    final expectedLength = expectedGraph.triples.length;
    expect(actualLength, closeTo(expectedLength, 10));
  });

  test('should fetch and register FOAF ontology by URL', () async {
    // Given
    final ontology = {
      "prefix": "RDF",
      "description": "Resource Description Framework",
      "downloadURL": "https://www.w3.org/1999/02/22-rdf-syntax-ns.rdf",
    };

    // When
    final result = await usecase.execute(
      url: ontology['downloadURL']!,
      prefix: ontology['prefix']!,
      description: ontology['description'],
    );

    // Then
    expect(result.isRight(), isTrue);

    // Verify the ontology is registered
    final getResult = await repository.getNamespaceByUri(
      uri: Uri.parse(ontology['downloadURL']!),
    );
    expect(getResult.isRight(), isTrue);
    final namespace = getResult.getRight().getOrElse(
      () => throw Exception('Should be right'),
    );
    expect(namespace.prefix, ontology['prefix']);
    expect(namespace.uri.toString(), ontology['downloadURL']);

    // Verify the RdfGraph is properly stored and retrieved
    expect(namespace.rdfGraph, isNotNull);
    expect(namespace.rdfGraph!.triples, isNotEmpty);
  });
}
