import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/services/fetch_content_service.dart';
import 'package:id_namespace/src/domain/core/services/rdf_parsing_service.dart';
import 'package:id_namespace/src/domain/core/usecases/fetch_and_register_ontology_usecase.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/utils/failures.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rdf_core/rdf_core.dart';
import 'package:test/test.dart';

class MockFetchContentService extends Mock implements FetchContentService {}

class MockRdfParsingService extends Mock implements RdfParsingService {}

class MockIdRegistryRepository extends Mock implements IdRegistryRepository {}

class FakeNamespace extends Fake implements Namespace {
  @override
  Uri get uri => Uri.parse('http://example.com');

  @override
  String get prefix => 'fake';

  @override
  String? get description => null;

  @override
  RdfGraph? get rdfGraph => null;
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeNamespace());
  });

  late MockFetchContentService mockFetchContentService;
  late MockRdfParsingService mockRdfParsingService;
  late MockIdRegistryRepository mockRepository;
  late FetchAndRegisterOntologyUsecase usecase;

  setUp(() {
    mockFetchContentService = MockFetchContentService();
    mockRdfParsingService = MockRdfParsingService();
    mockRepository = MockIdRegistryRepository();
    usecase = FetchAndRegisterOntologyUsecase(
      fetchContentService: mockFetchContentService,
      rdfParsingService: mockRdfParsingService,
      repository: mockRepository,
    );
  });

  group('FetchAndRegisterOntologyUsecase', () {
    const url = 'https://example.com/ontology.rdf';
    const prefix = 'EX';
    const description = 'Example Ontology';

    test('should return failure when fetchContent fails', () async {
      // Given
      final failure = NetworkFailure('Failed to fetch content');
      when(() => mockFetchContentService.fetchContent(url))
          .thenAnswer((_) async => Left(failure));

      // When
      final result = await usecase.execute(
        url: url,
        prefix: prefix,
        description: description,
      );

      // Then
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().getOrElse(() => throw Exception('Should be left')), failure);
      verify(() => mockFetchContentService.fetchContent(url)).called(1);
      verifyNever(() => mockRdfParsingService.parseRdf(any(), any()));
      verifyNever(() => mockRepository.add(namespace: any(named: 'namespace')));
    });

    test('should return failure when parseRdf fails', () async {
      // Given
      const content = '<rdf:RDF></rdf:RDF>';
      final fetchResult = Right<Failure, String>(content);
      final parseFailure = ParseFailure('Failed to parse RDF');
      when(() => mockFetchContentService.fetchContent(url))
          .thenAnswer((_) async => fetchResult);
      when(() => mockRdfParsingService.parseRdf(content, url))
          .thenAnswer((_) async => Left(parseFailure));

      // When
      final result = await usecase.execute(
        url: url,
        prefix: prefix,
        description: description,
      );

      // Then
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().getOrElse(() => throw Exception('Should be left')), parseFailure);
      verify(() => mockFetchContentService.fetchContent(url)).called(1);
      verify(() => mockRdfParsingService.parseRdf(content, url)).called(1);
      verifyNever(() => mockRepository.add(namespace: any(named: 'namespace')));
    });

    test('should return failure when repository add fails', () async {
      // Given
      const content = '<rdf:RDF></rdf:RDF>';
      final fetchResult = Right<Failure, String>(content);
      final rdfGraph = RdfGraph(triples: []);
      final parseResult = Right<Failure, RdfGraph>(rdfGraph);
      final addFailure = StorageFailure('Failed to add namespace');
      when(() => mockFetchContentService.fetchContent(url))
          .thenAnswer((_) async => fetchResult);
      when(() => mockRdfParsingService.parseRdf(content, url))
          .thenAnswer((_) async => parseResult);
      when(() => mockRepository.add(namespace: any(named: 'namespace')))
          .thenAnswer((_) async => Left(addFailure));

      // When
      final result = await usecase.execute(
        url: url,
        prefix: prefix,
        description: description,
      );

      // Then
      expect(result.isLeft(), isTrue);
      expect(result.getLeft().getOrElse(() => throw Exception('Should be left')), addFailure);
      verify(() => mockFetchContentService.fetchContent(url)).called(1);
      verify(() => mockRdfParsingService.parseRdf(content, url)).called(1);
      verify(() => mockRepository.add(namespace: any(named: 'namespace'))).called(1);
    });

    test('should succeed when all steps succeed', () async {
      // Given
      const content = '<rdf:RDF></rdf:RDF>';
      final fetchResult = Right<Failure, String>(content);
      final rdfGraph = RdfGraph(triples: []);
      final parseResult = Right<Failure, RdfGraph>(rdfGraph);
      final addResult = Right<Failure, Unit>(unit);
      when(() => mockFetchContentService.fetchContent(url))
          .thenAnswer((_) async => fetchResult);
      when(() => mockRdfParsingService.parseRdf(content, url))
          .thenAnswer((_) async => parseResult);
      when(() => mockRepository.add(namespace: any(named: 'namespace')))
          .thenAnswer((_) async => addResult);

      // When
      final result = await usecase.execute(
        url: url,
        prefix: prefix,
        description: description,
      );

      // Then
      expect(result.isRight(), isTrue);
      verify(() => mockFetchContentService.fetchContent(url)).called(1);
      verify(() => mockRdfParsingService.parseRdf(content, url)).called(1);
      verify(() => mockRepository.add(namespace: any(named: 'namespace'))).called(1);
    });
  });
}