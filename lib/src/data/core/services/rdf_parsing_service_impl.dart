import 'package:fpdart/fpdart.dart';
import 'package:rdf_core/rdf_core.dart';
import 'package:rdf_xml/rdf_xml.dart';

import '../../../domain/core/services/rdf_parsing_service.dart';
import '../../../utils/failures.dart';

/// Implementation of RdfParsingService using rdf_core and rdf_xml libraries.
class RdfParsingServiceImpl implements RdfParsingService {
  @override
  Future<Either<Failure, RdfGraph>> parseRdf(String content, String url) async {
    try {
      final format = _getFormatFromUrl(url);
      final graph = _parseRdfContent(content, format);
      return Right(graph);
    } catch (e) {
      return Left(ParseFailure('Failed to parse RDF: $e'));
    }
  }

  /// Determines RDF format from URL path.
  String _getFormatFromUrl(String path) {
    if (path.endsWith('.ttl') || path.endsWith('.turtle')) {
      return 'turtle';
    } else if (path.endsWith('.rdf') || path.endsWith('.xml')) {
      return 'rdfxml';
    } else if (path.endsWith('.nt')) {
      return 'ntriples';
    } else if (path.endsWith('.jsonld')) {
      return 'jsonld';
    } else {
      return 'turtle'; // default
    }
  }

  /// Parses RDF content into an [RdfGraph].
  RdfGraph _parseRdfContent(String content, String format) {
    switch (format) {
      case 'rdfxml':
        return rdfxml.decode(content);
      default:
        String contentType;
        switch (format) {
          case 'turtle':
            contentType = 'text/turtle';
            break;
          case 'ntriples':
            contentType = 'application/n-triples';
            break;
          case 'jsonld':
            contentType = 'application/ld+json';
            break;
          default:
            contentType = 'text/turtle'; // default to turtle
        }
        return rdf.decode(content, contentType: contentType);
    }
  }
}
