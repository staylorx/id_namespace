import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/src/data/core/services/fetch_content_service_impl.dart';
import 'package:id_namespace/src/domain/core/services/fetch_content_service.dart';
import 'package:id_namespace/src/utils/failures.dart';
import 'package:test/test.dart';

void main() {
  late FetchContentService service;

  setUp(() {
    service = FetchContentServiceImpl();
  });

  group('FetchContentServiceImpl', () {
    test('should fetch content from file URL', () async {
      // Given
      final testContent = 'test RDF content';
      final tempFile = File('${Directory.systemTemp.path}/test.rdf');
      await tempFile.writeAsString(testContent);
      final fileUrl = 'file://${tempFile.path}';

      // When
      final result = await service.fetchContent(fileUrl);

      // Then
      expect(result.isRight(), isTrue);
      expect(result.getRight().getOrElse(() => ''), testContent);

      // Cleanup
      await tempFile.delete();
    });

    test('should return NetworkFailure for invalid file URL', () async {
      // Given
      final invalidUrl = 'file:///nonexistent/path.rdf';

      // When
      final result = await service.fetchContent(invalidUrl);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<NetworkFailure>());
    });

    // Note: HTTP tests would require mocking Dio or using a test server
    // For now, we focus on file fetching as it's testable without external deps
  });
}
