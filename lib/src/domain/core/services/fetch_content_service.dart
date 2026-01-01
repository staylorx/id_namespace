import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';

/// Service interface for fetching content from URLs or files.
abstract class FetchContentService {
  /// Fetches content from the given URL.
  ///
  /// Supports both HTTP/HTTPS URLs and file:// URLs.
  /// Returns [NetworkFailure] if fetching fails.
  Future<Either<Failure, String>> fetchContent({required String url});
}
