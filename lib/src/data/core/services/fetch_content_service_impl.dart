import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/utils/logging.dart';

import '../../../domain/core/services/fetch_content_service.dart';
import '../../../utils/failures.dart';

/// Implementation of FetchContentService using Dio for HTTP and File for local files.
class FetchContentServiceImpl implements FetchContentService {
  final Dio _dio;
  final _logger = Logging.getLogger('FetchContentServiceImpl');

  FetchContentServiceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<Either<Failure, String>> fetchContent({required String url}) async {
    _logger.info('Attempting to fetch content from URL: $url');
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == 'file') {
        _logger.info(
          'Detected file scheme, reading from file path: ${uri.toFilePath()}',
        );
        final filePath = uri.toFilePath();
        final file = File(filePath);
        final content = await file.readAsString();
        _logger.info(
          'Successfully read ${content.length} characters from file',
        );
        return Right(content);
      } else {
        _logger.info('Detected HTTP scheme, making GET request to: $url');
        _dio.options.receiveTimeout = Duration(seconds: 30);
        final response = await _dio.get(url);
        if (response.statusCode != 200) {
          final errorMsg =
              'Failed to fetch content from $url: HTTP ${response.statusCode}';
          _logger.severe(errorMsg);
          return Left(NetworkFailure(errorMsg));
        }
        final content = response.data as String;
        _logger.info(
          'Successfully fetched ${content.length} characters from $url',
        );
        return Right(content);
      }
    } on DioException catch (e) {
      final errorMsg =
          'Network error fetching $url: ${e.message} (type: ${e.type})';
      _logger.severe(errorMsg);
      return Left(NetworkFailure(errorMsg));
    } catch (e) {
      final errorMsg = 'Failed to fetch content from $url: $e';
      _logger.severe(errorMsg);
      return Left(NetworkFailure(errorMsg));
    }
  }
}
