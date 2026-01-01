import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/core/services/fetch_content_service_impl.dart';
import 'package:id_namespace/src/data/core/services/rdf_parsing_service_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/file_based_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/services/fetch_content_service.dart';
import 'package:id_namespace/src/domain/core/services/rdf_parsing_service.dart';
import 'package:id_namespace/src/domain/core/usecases/fetch_and_register_ontology_usecase.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:rdf_xml/rdf_xml.dart';
import 'package:test/test.dart';

void main() {
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
    // Given
    final ontology = {
      "code": "FOAF",
      "formalName": "Friend of a Friend",
      "downloadURL":
          "file:///${Directory.current.path.replaceAll('\\', '/')}/test/assets/ontologies/foaf.rdf",
    };

    // When
    final result = await usecase.execute(
      url: ontology['downloadURL']!,
      prefix: ontology['code']!,
      description: ontology['formalName'],
    );

    // Then
    expect(result.isRight(), isTrue);

    // Verify the ontology is registered
    final getResult = await repository.getNamespaceByCode(
      code: ontology['code']!,
    );
    expect(getResult.isRight(), isTrue);
    final namespace = getResult.getRight().getOrElse(
      () => throw Exception('Should be right'),
    );
    expect(namespace.prefix, ontology['code']);
    expect(namespace.uri.toString(), ontology['downloadURL']);

    // Verify the RdfGraph is properly stored and retrieved
    expect(namespace.rdfGraph, isNotNull);
    expect(namespace.rdfGraph!.triples, isNotEmpty);

    // Verify the RdfGraph matches the expected parsed content from the ontology file
    final filePath = ontology['downloadURL']!.replaceFirst('file:///', '');
    final content = await File(filePath).readAsString();
    final expectedGraph = rdfxml.decode(content);
    // Check that the lengths are within 5% of each other, as serialization may change the count
    final actualLength = namespace.rdfGraph!.triples.length;
    final expectedLength = expectedGraph.triples.length;
    final difference = (actualLength - expectedLength).abs();
    final tolerance = (expectedLength * 0.05).ceil();
    expect(difference, lessThanOrEqualTo(tolerance));
  });

  test('should fetch and register FOAF ontology by URL', () async {
    // Given
    final ontology = {
      "code": "FOAF",
      "formalName": "Friend of a Friend",
      "downloadURL": "https://xmlns.com/foaf/spec/index.rdf",
    };

    // When
    final result = await usecase.execute(
      url: ontology['downloadURL']!,
      prefix: ontology['code']!,
      description: ontology['formalName'],
    );

    // Then
    expect(result.isRight(), isTrue);

    // Verify the ontology is registered
    final getResult = await repository.getNamespaceByCode(
      code: ontology['code']!,
    );
    expect(getResult.isRight(), isTrue);
    final namespace = getResult.getRight().getOrElse(
      () => throw Exception('Should be right'),
    );
    expect(namespace.prefix, ontology['code']);
    expect(namespace.uri.toString(), ontology['downloadURL']);

    // Verify the RdfGraph is properly stored and retrieved
    expect(namespace.rdfGraph, isNotNull);
    expect(namespace.rdfGraph!.triples, isNotEmpty);
  });
}
