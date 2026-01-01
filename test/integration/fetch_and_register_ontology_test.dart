import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/repositories/id_registry_repository_impl.dart';
import 'package:id_namespace/src/data/storage/repositories/file_based_id_storage.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/usecases/fetch_and_register_ontology_usecase.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:path/path.dart' as path;
import 'package:rdf_core/rdf_core.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String storageFilePath;
  late IdStorage storage;
  late IdRegistryRepository repository;
  late FetchAndRegisterOntologyUsecase usecase;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('id_namespace_test_');
    storageFilePath = path.join(tempDir.path, 'registry.json');
    storage = FileBasedIdStorage(filePath: storageFilePath);
    repository = IdRegistryRepositoryImpl(storage: storage);
    usecase = FetchAndRegisterOntologyUsecase(repository: repository);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('should fetch and register FOAF ontology', () async {
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
    final namespaces = getResult.getRight().getOrElse(() => {});
    expect(namespaces.length, 1);
    final namespace = namespaces.first;
    expect(namespace.prefix, ontology['code']);
    expect(namespace.uri.toString(), ontology['downloadURL']);

    // Verify the RdfGraph is properly stored and retrieved
    expect(namespace.rdfGraph, isNotNull);
    expect(namespace.rdfGraph!.triples, isNotEmpty);

    // Verify the RdfGraph matches the expected parsed content from the ontology file
    final filePath = ontology['downloadURL']!.replaceFirst('file:///', '');
    final content = await File(filePath).readAsString();
    final expectedGraph = rdf.decode(
      content,
      contentType: 'application/rdf+xml',
    );
    expect(
      namespace.rdfGraph!.triples.length,
      equals(expectedGraph.triples.length),
    );
  });
}
