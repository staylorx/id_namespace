import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    Logger.root.level = Level.WARNING;
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
  late GetAllNamespacesUsecase getAllUsecase;
  late GetNamespaceByPrefixUsecase getByPrefixUsecase;
  late GetNamespaceByUriUsecase getByUriUsecase;
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
    getByPrefixUsecase = GetNamespaceByPrefixUsecase(repository: repository);
    getByUriUsecase = GetNamespaceByUriUsecase(repository: repository);
  });

  tearDown(() async {
    final file = File(tempFilePath);
    if (await file.exists()) await file.delete();
    final dir = Directory(tempFilePath).parent;
    if (await dir.exists()) await dir.delete();
  });

  group('Ontology Loading - Storage and Registry Integration', () {
    test('should persist ontology data in storage after loading', () async {
      final file = File("test/assets/formats/example.ttl");

      // Load ontology
      final result = await usecase.execute(
        url: Uri.file(file.absolute.path).toString(),
        prefix: "EX",
        description: "Example ontology",
      );

      expect(result.isRight(), isTrue);

      // Check that registry has the data via getAll
      final allResult = await getAllUsecase.execute();
      expect(allResult.isRight(), isTrue);
      final namespaces = allResult.getRight().getOrElse(() => {});
      expect(namespaces.length, 1);

      // Check via getNamespaceByPrefix
      final byPrefixResult = await getByPrefixUsecase.execute(prefix: "EX");
      expect(byPrefixResult.isRight(), isTrue);
      final namespace = byPrefixResult.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(namespace.prefix, "EX");
      expect(namespace.description, "Example ontology");
      expect(namespace.rdfGraph, isNotNull);
      expect(namespace.rdfGraph!.triples, isNotEmpty);
    });

    test('should allow querying loaded ontologies via registry', () async {
      final file = File("test/assets/formats/example.ttl");

      // Load ontology
      final loadResult = await usecase.execute(
        url: Uri.file(file.absolute.path).toString(),
        prefix: "EX",
        description: "Example ontology",
      );
      expect(loadResult.isRight(), isTrue);

      // Query by prefix
      final byPrefixResult = await getByPrefixUsecase.execute(prefix: "EX");
      expect(byPrefixResult.isRight(), isTrue);
      final namespace = byPrefixResult.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(namespace.prefix, "EX");

      // Query by URI
      final byUriResult = await getByUriUsecase.execute(
        uri: Uri.parse(Uri.file(file.absolute.path).toString()),
      );
      expect(byUriResult.isRight(), isTrue);
      final namespaceByUri = byUriResult.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      expect(namespaceByUri.prefix, "EX");

      // Get all namespaces
      final allResult = await getAllUsecase.execute();
      expect(allResult.isRight(), isTrue);
      final allNamespaces = allResult.getRight().getOrElse(() => {});
      expect(allNamespaces.length, 1);
    });

    test('should handle multiple ontology loading and storage', () async {
      final ttlFile = File("test/assets/formats/example.ttl");
      final jsonldFile = File("test/assets/formats/example.jsonld");

      // Load first ontology
      final result1 = await usecase.execute(
        url: Uri.file(ttlFile.absolute.path).toString(),
        prefix: "TTL",
        description: "Turtle ontology",
      );
      expect(result1.isRight(), isTrue);

      // Load second ontology
      final result2 = await usecase.execute(
        url: Uri.file(jsonldFile.absolute.path).toString(),
        prefix: "JSONLD",
        description: "JSON-LD ontology",
      );
      expect(result2.isRight(), isTrue);

      // Check registry has both
      final allResult = await getAllUsecase.execute();
      expect(allResult.isRight(), isTrue);
      final allNamespaces = allResult.getRight().getOrElse(() => {});
      expect(allNamespaces.length, 2);

      final ttlByPrefix = await getByPrefixUsecase.execute(prefix: "TTL");
      expect(ttlByPrefix.isRight(), isTrue);

      final jsonldByPrefix = await getByPrefixUsecase.execute(prefix: "JSONLD");
      expect(jsonldByPrefix.isRight(), isTrue);
    });

    test('should maintain data integrity after storage operations', () async {
      final file = File("test/assets/formats/example.ttl");

      // Load ontology
      final loadResult = await usecase.execute(
        url: Uri.file(file.absolute.path).toString(),
        prefix: "EX",
        description: "Example ontology",
      );
      expect(loadResult.isRight(), isTrue);

      // Get the namespace
      final getResult = await getByPrefixUsecase.execute(prefix: "EX");
      expect(getResult.isRight(), isTrue);
      final originalNamespace = getResult.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );
      final originalTripleCount = originalNamespace.rdfGraph!.triples.length;

      // Simulate storage reload by creating new repository instance
      final newRepository = IdRegistryRepositoryImpl(storage: storage);
      final newGetByPrefixUsecase = GetNamespaceByPrefixUsecase(
        repository: newRepository,
      );

      // Query again
      final reloadedResult = await newGetByPrefixUsecase.execute(prefix: "EX");
      expect(reloadedResult.isRight(), isTrue);
      final reloadedNamespace = reloadedResult.getRight().getOrElse(
        () => throw Exception('Should be right'),
      );

      // Verify data integrity
      expect(reloadedNamespace.prefix, originalNamespace.prefix);
      expect(reloadedNamespace.description, originalNamespace.description);
      expect(reloadedNamespace.uri, originalNamespace.uri);
      expect(reloadedNamespace.rdfGraph!.triples.length, originalTripleCount);
    });
  });
}
