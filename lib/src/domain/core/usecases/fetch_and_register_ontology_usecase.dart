import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../services/fetch_content_service.dart';
import '../services/rdf_parsing_service.dart';
import '../value_objects/namespace.dart';

/// Usecase for fetching and registering an ontology from the internet.
class FetchAndRegisterOntologyUsecase {
  final _logger = Logger('FetchAndRegisterOntologyUsecase');

  final FetchContentService fetchContentService;
  final RdfParsingService rdfParsingService;
  final IdRegistryRepository repository;

  FetchAndRegisterOntologyUsecase({
    required this.fetchContentService,
    required this.rdfParsingService,
    required this.repository,
  });

  /// Executes the usecase to fetch and register an ontology.
  Future<Either<Failure, Unit>> execute({
    required String url,
    required String prefix,
    String? description,
  }) async {
    _logger.info('Starting execution for URL: $url, prefix: $prefix');
    // Step 1: Fetch content
    _logger.info('Step 1 - Fetching content...');
    final contentEither = await fetchContentService.fetchContent(url: url);
    return await contentEither.match(
      (failure) {
        _logger.severe('Step 1 failed - $failure');
        return Future.value(Left(failure));
      },
      (content) async {
        _logger.info('Step 1 succeeded - fetched ${content.length} characters');
        // Step 2: Parse RDF
        _logger.info('Step 2 - Parsing RDF...');
        final rdfEither = await rdfParsingService.parseRdf(content, url);
        return await rdfEither.match(
          (failure) {
            _logger.severe('Step 2 failed - $failure');
            return Future.value(Left(failure));
          },
          (rdfGraph) async {
            _logger.info(
              'Step 2 succeeded - parsed ${rdfGraph.triples.length} triples',
            );
            // Step 3: Create namespace
            _logger.info('Step 3 - Creating namespace...');
            final uri = Uri.parse(url);
            final namespace = Namespace(
              uri: uri,
              prefix: prefix,
              description: description,
              rdfGraph: rdfGraph,
            );
            _logger.info(
              'Step 3 succeeded - created namespace with prefix $prefix',
            );

            // Step 4: Add to repository
            _logger.info('Step 4 - Adding to repository...');
            final addResult = await repository.add(namespace: namespace);
            return addResult.match(
              (failure) {
                _logger.severe('Step 4 failed - $failure');
                return Left(failure);
              },
              (unit) {
                _logger.info('Step 4 succeeded - ontology registered');
                return Right(unit);
              },
            );
          },
        );
      },
    );
  }
}
