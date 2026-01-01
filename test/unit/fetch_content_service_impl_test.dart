import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:id_namespace/id_namespace.dart';
import 'package:test/test.dart';

// Mock Dio for testing HTTP requests
class MockDio extends Mock implements Dio {}

void main() {
  late FetchContentService service;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    // Mock the options to avoid issues
    when(() => mockDio.options).thenReturn(BaseOptions());
    service = FetchContentServiceImpl(dio: mockDio);
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

    test('should return NetworkFailure for malformed URL', () async {
      // Given
      final malformedUrl = 'not-a-url';

      // When
      final result = await service.fetchContent(url: malformedUrl);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<NetworkFailure>());
    });

    test('should return NetworkFailure for empty URL', () async {
      // Given
      final emptyUrl = '';

      // When
      final result = await service.fetchContent(url: emptyUrl);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<NetworkFailure>());
    });

    test('should fetch content from HTTP URL', () async {
      // Given
      const url = 'http://example.com/test.rdf';
      const content = 'mock content';
      final mockResponse = Response(
        data: content,
        statusCode: 200,
        requestOptions: RequestOptions(path: url),
      );
      when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

      // When
      final result = await service.fetchContent(url: url);

      // Then
      expect(result.isRight(), isTrue);
      expect(result.getRight().getOrElse(() => ''), content);
    });

    test('should return NetworkFailure for HTTP error status code', () async {
      // Given
      const url = 'http://example.com/test.rdf';
      final mockResponse = Response(
        data: 'error',
        statusCode: 404,
        requestOptions: RequestOptions(path: url),
      );
      when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

      // When
      final result = await service.fetchContent(url: url);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<NetworkFailure>());
    });

    test(
      'should return NetworkFailure for DioException (network error)',
      () async {
        // Given
        const url = 'http://example.com/test.rdf';
        when(() => mockDio.get(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.connectionError,
            message: 'Connection failed',
          ),
        );

        // When
        final result = await service.fetchContent(url: url);

        // Then
        expect(result.isLeft(), isTrue);
        final failure = result.getLeft().getOrElse(
          () => throw Exception('Should be left'),
        );
        expect(failure, isA<NetworkFailure>());
      },
    );

    test('should return NetworkFailure for timeout', () async {
      // Given
      const url = 'http://example.com/test.rdf';
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: url),
          type: DioExceptionType.receiveTimeout,
          message: 'Receive timeout',
        ),
      );

      // When
      final result = await service.fetchContent(url: url);

      // Then
      expect(result.isLeft(), isTrue);
      final failure = result.getLeft().getOrElse(
        () => throw Exception('Should be left'),
      );
      expect(failure, isA<NetworkFailure>());
    });
  });
}
