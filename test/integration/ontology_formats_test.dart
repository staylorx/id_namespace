import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:logging/logging.dart';
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

  group('Ontology Loading - Different Formats', () {
    test('should load and register ontology in Turtle format', () async {
      final file = File("test/assets/formats/example.ttl");

      final result = await usecase.execute(
        url: Uri.file(file.absolute.path).toString(),
        prefix: "EX",
        description: "Example ontology in Turtle format",
      );

      expect(result.isRight(), isTrue);

      final getResult = await repository.getNamespaceByUri(
        uri: Uri.parse(Uri.file(file.absolute.path).toString()),
      );
      expect(getResult.isRight(), isTrue);
      final namespace = getResult.getRight().getOrElse(() => throw Exception('Should be right'));
      expect(namespace.prefix, "EX");
      expect(namespace.rdfGraph, isNotNull);
      expect(namespace.rdfGraph!.triples, isNotEmpty);
    });

    test('should load and register ontology in RDF/XML format', () async {
      final file = File("test/assets/formats/example.rdf");

      final result = await usecase.execute(
        url: Uri.file(file.absolute.path).toString(),
        prefix: "EX",
        description: "Example ontology in RDF/XML format",
      );

      expect(result.isRight(), isTrue);

      final getResult = await repository.getNamespaceByUri(
        uri: Uri.parse(Uri.file(file.absolute.path).toString()),
      );
      expect(getResult.isRight(), isTrue);
      final namespace = getResult.getRight().getOrElse(() => throw Exception('Should be right'));
      expect(namespace.prefix, "EX");
      expect(namespace.rdfGraph, isNotNull);
      expect(namespace.rdfGraph!.triples, isNotEmpty);
    });

    test('should load and register ontology in JSON-LD format', () async {
      final file = File("test/assets/formats/example.jsonld");

      final result = await usecase.execute(
        url: Uri.file(file.absolute.path).toString(),
        prefix: "EX",
        description: "Example ontology in JSON-LD format",
      );

      expect(result.isRight(), isTrue);

      final getResult = await repository.getNamespaceByUri(
        uri: Uri.parse(Uri.file(file.absolute.path).toString()),
      );
      expect(getResult.isRight(), isTrue);
      final namespace = getResult.getRight().getOrElse(() => throw Exception('Should be right'));
      expect(namespace.prefix, "EX");
      expect(namespace.rdfGraph, isNotNull);
      expect(namespace.rdfGraph!.triples, isNotEmpty);
    });

    test('should load and register ontology in N-Triples format', () async {
      final file = File("test/assets/formats/example.nt");

      final result = await usecase.execute(
        url: Uri.file(file.absolute.path).toString(),
        prefix: "EX",
        description: "Example ontology in N-Triples format",
      );

      expect(result.isRight(), isTrue);

      final getResult = await repository.getNamespaceByUri(
        uri: Uri.parse(Uri.file(file.absolute.path).toString()),
      );
      expect(getResult.isRight(), isTrue);
      final namespace = getResult.getRight().getOrElse(() => throw Exception('Should be right'));
      expect(namespace.prefix, "EX");
      expect(namespace.rdfGraph, isNotNull);
      expect(namespace.rdfGraph!.triples, isNotEmpty);
    });
  });
}