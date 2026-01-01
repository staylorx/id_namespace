import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rdf_core/rdf_core.dart';

import 'package:id_namespace/src/utils/failures.dart';
import 'package:id_namespace/src/domain/core/repositories/id_registry_repository.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';
import 'package:id_namespace/src/domain/storage/repositories/storage.dart';
import 'package:id_namespace/src/data/core/models/namespace_dto.dart';

/// Implementation of IdRegistryRepository using IdStorage.
class IdRegistryRepositoryImpl implements IdRegistryRepository {
  final IdStorage storage;

  IdRegistryRepositoryImpl({required this.storage});

  /// Registers the namespace.
  @override
  Future<Either<Failure, Unit>> add({required Namespace namespace}) async {
    return await storage.add(namespace);
  }

  /// Unregisters the namespace.
  @override
  Future<Either<Failure, Unit>> remove({required Namespace namespace}) async {
    return await storage.remove(namespace);
  }

  /// Checks if the namespace is registered.
  @override
  Future<Either<Failure, bool>> isRegistered({
    required Namespace namespace,
  }) async {
    return await storage.contains(namespace);
  }

  /// Returns namespace by prefix.
  @override
  Future<Either<Failure, Namespace>> getNamespaceByPrefix({
    required String prefix,
  }) async {
    final allResult = await getAll();
    return allResult.fold(
      (failure) => Left(failure),
      (allNamespaces) {
        try {
          final namespace = allNamespaces.firstWhere((ns) => ns.prefix == prefix);
          return Right(namespace);
        } catch (e) {
          return Left(NotFoundFailure('Namespace with prefix $prefix not found'));
        }
      },
    );
  }

  /// Returns namespace by code.
  @override
  Future<Either<Failure, Namespace>> getNamespaceByCode({
    required String code,
  }) async {
    final allResult = await getAll();
    return allResult.fold(
      (failure) => Left(failure),
      (allNamespaces) {
        try {
          final namespace = allNamespaces.firstWhere((ns) => ns.prefix == code);
          return Right(namespace);
        } catch (e) {
          return Left(NotFoundFailure('Namespace with code $code not found'));
        }
      },
    );
  }

  /// Returns all registered namespaces.
  @override
  Future<Either<Failure, Set<Namespace>>> getAll() async {
    return await storage.getAll();
  }

  /// Clears all registrations.
  @override
  Future<Either<Failure, Unit>> clear() async {
    return await storage.clear();
  }

  /// Fetches an ontology file from the internet and registers it.
  @override
  Future<Either<Failure, Unit>> fetchAndRegisterOntology({
    required String url,
    required String prefix,
    String? description,
  }) async {
    try {
      final uri = Uri.parse(url);
      final String content;
      if (uri.scheme == 'file') {
        final file = File(uri.toFilePath());
        content = await file.readAsString();
      } else {
        final dio = Dio();
        final response = await dio.get(url);
        if (response.statusCode != 200) {
          return Left(
            NetworkFailure('Failed to fetch ontology: ${response.statusCode}'),
          );
        }
        content = response.data as String;
      }

      // Determine format from URL extension
      final format = _getFormatFromUrl(uri.path);

      // Parse RDF content
      final RdfGraph rdfGraph = _parseRdfContent(content, format);

      final namespace = Namespace(
        uri: uri,
        prefix: prefix,
        description: description,
        rdfGraph: rdfGraph,
      );

      return await add(namespace: namespace);
    } on DioException catch (e) {
      return Left(NetworkFailure('Network error: ${e.message}'));
    } catch (e) {
      return Left(ParseFailure('Failed to parse RDF: $e'));
    }
  }

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

  RdfGraph _parseRdfContent(String content, String format) {
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
      case 'rdfxml':
        contentType = 'application/rdf+xml';
        break;
      default:
        contentType = 'text/turtle'; // default to turtle
    }
    return rdf.decode(content, contentType: contentType);
  }
}
