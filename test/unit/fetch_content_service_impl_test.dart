import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:test/test.dart';

void main() {
  late FetchContentService service;

  setUp(() {
    service = FetchContentServiceImpl();
  });

  group('FetchContentServiceImpl', () {
    test('should fetch content from file URL', () async {
      // Given
      final file = File('test/assets/formats/example.rdf');
      final expectedContent = await file.readAsString();
      final fileUrl = Uri.file(file.absolute.path).toString();

      // When
      final result = await service.fetchContent(url: fileUrl);

      // Then
      expect(result.isRight(), isTrue);
      expect(result.getRight().getOrElse(() => ''), expectedContent);
    });

    test('should return NetworkFailure for invalid file URL', () async {
      // Given
      final invalidUrl = 'file:///nonexistent/path.rdf';

      // When
      final result = await service.fetchContent(url: invalidUrl);

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
