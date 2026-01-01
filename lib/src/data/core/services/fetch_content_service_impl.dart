import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../domain/core/services/fetch_content_service.dart';
import '../../../utils/failures.dart';

/// Implementation of FetchContentService using Dio for HTTP and File for local files.
class FetchContentServiceImpl implements FetchContentService {
  @override
  Future<Either<Failure, String>> fetchContent(String url) async {
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == 'file') {
        final file = File(uri.toFilePath());
        final content = await file.readAsString();
        return Right(content);
      } else {
        final dio = Dio();
        final response = await dio.get(url);
        if (response.statusCode != 200) {
          return Left(
            NetworkFailure('Failed to fetch content: ${response.statusCode}'),
          );
        }
        final content = response.data as String;
        return Right(content);
      }
    } on DioException catch (e) {
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(NetworkFailure('Failed to fetch content: $e'));
    }
  }
}
