import 'package:fpdart/fpdart.dart';
import 'package:rdf_core/rdf_core.dart';

import '../../../utils/failures.dart';

/// Service interface for parsing RDF content.
abstract class RdfParsingService {
  /// Parses RDF content into an [RdfGraph].
  ///
  /// Determines the format from the URL path if not provided.
  /// Returns [ParseFailure] if parsing fails.
  Either<Failure, RdfGraph> parseRdf({
    required String content,
    required String url,
  });
}
