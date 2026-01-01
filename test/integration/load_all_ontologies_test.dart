import 'dart:convert';
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
import 'package:id_namespace/src/domain/core/usecases/get_all_namespaces_usecase.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:test/test.dart';

void main() {
  late IdStorage storage;
  late IdRegistryRepository repository;
  late FetchContentService fetchContentService;
  late RdfParsingService rdfParsingService;
  late FetchAndRegisterOntologyUsecase usecase;
  late GetAllNamespacesUsecase getAllUsecase;
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
    getAllUsecase = GetAllNamespacesUsecase(repository: repository);
  });

  tearDown(() async {
    final file = File(tempFilePath);
    if (await file.exists()) await file.delete();
    final dir = Directory(tempFilePath).parent;
    if (await dir.exists()) await dir.delete();
  });

  test('should load all ontologies from JSON and register them', () async {
    // Read ontologies.json
    final ontologiesFile = File('test/assets/ontologies.json');
    final content = await ontologiesFile.readAsString();
    final jsonData = json.decode(content) as Map<String, dynamic>;
    final ontologies = jsonData['ontologies'] as List<dynamic>;

    // For each ontology, execute usecase
    for (final ontology in ontologies) {
      final result = await usecase.execute(
        url: ontology['downloadURL'] as String,
        prefix: ontology['code'] as String,
        description: ontology['formalName'] as String,
      );
      expect(result.isRight(), isTrue, reason: 'Failed to register ${ontology['code']}');
    }

    // Verify all are registered
    final allResult = await getAllUsecase.execute();
    expect(allResult.isRight(), isTrue);
    final namespaces = allResult.getRight().getOrElse(() => {});
    expect(namespaces.length, ontologies.length);
  }, timeout: Timeout(Duration(minutes: 10)));
}