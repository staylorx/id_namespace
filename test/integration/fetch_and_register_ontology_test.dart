import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/in_memory_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/fetch_and_register_ontology_usecase.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:rdf_xml/rdf_xml.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late FetchAndRegisterOntologyUsecase usecase;

  setUp(() {
    // TODO: replace with file-based storage implementation, using temporary files for testing
    storage = InMemoryIdStorage();
    repository = IdRegistryRepositoryImpl(storage: storage);
    usecase = FetchAndRegisterOntologyUsecase(repository: repository);
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
    expect(
      namespace.rdfGraph!.triples.length,
      equals(expectedGraph.triples.length),
    );
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

    // Verify the RdfGraph matches the expected parsed content from the ontology file
    final filePath = ontology['downloadURL']!.replaceFirst('file:///', '');
    final content = await File(filePath).readAsString();
    final expectedGraph = rdfxml.decode(content);
    expect(
      namespace.rdfGraph!.triples.length,
      equals(expectedGraph.triples.length),
    );
  });
}
