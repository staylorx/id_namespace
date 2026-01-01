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

  group('Ontology Loading - Network Failures', () {
    test(
      'should handle 404 Not Found gracefully',
      () async {
        final result = await usecase.execute(
          url: "http://httpstat.us/404",
          prefix: "NOTFOUND",
          description: "Non-existent ontology",
        );

        expect(result.isLeft(), isTrue);
        // Should be a NetworkFailure
        final failure = result.getLeft().getOrElse(
          () => throw Exception('Should be left'),
        );
        expect(failure, isA<NetworkFailure>());
      },
      timeout: Timeout(Duration(seconds: 30)),
    );

    test(
      'should handle invalid domain gracefully',
      () async {
        final result = await usecase.execute(
          url: "http://invalid.domain.that.does.not.exist.ever/ontology.ttl",
          prefix: "INVALID",
          description: "Invalid domain ontology",
        );

        expect(result.isLeft(), isTrue);
        final failure = result.getLeft().getOrElse(
          () => throw Exception('Should be left'),
        );
        expect(failure, isA<NetworkFailure>());
      },
      timeout: Timeout(Duration(seconds: 30)),
    );

    test('should handle malformed URL gracefully', () async {
      final result = await usecase.execute(
        url: "not-a-valid-url",
        prefix: "MALFORMEDURL",
        description: "Malformed URL ontology",
      );

      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<NetworkFailure>());
    });

    test('should handle timeout gracefully', () async {
      // Use a URL that might timeout
      final result = await usecase.execute(
        url: "http://httpstat.us/200?sleep=10000", // 10 second delay
        prefix: "TIMEOUT",
        description: "Timeout ontology",
      );

      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<NetworkFailure>());
    }, timeout: Timeout(Duration(seconds: 15))); // Shorter timeout for test

    test('should handle unsupported protocol gracefully', () async {
      final result = await usecase.execute(
        url: "ftp://example.com/ontology.ttl",
        prefix: "FTP",
        description: "FTP protocol ontology",
      );

      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<NetworkFailure>());
    });
  });
}
