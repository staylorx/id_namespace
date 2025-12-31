import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../domain/storage/repositories/storage.dart';
import '../../../domain/core/failures.dart';
import '../../../domain/core/value_objects/namespace.dart';

/// File-based implementation of AsyncIdStorage that persists data to JSON files asynchronously.
///
/// This implementation demonstrates how to create a persistent async storage layer
/// that saves and loads data from a JSON file on disk using async I/O.
class FileBasedIdStorage implements IdStorage {
  final String filePath;
  Map<String, dynamic> _data = {'ids': <String, Set<String>>{}};
  bool _loaded = false;

  /// Creates a file-based async storage with the specified file path.
  ///
  /// Data is loaded lazily on first access to avoid async constructor.
  FileBasedIdStorage({required this.filePath});

  /// Loads data from the JSON file into memory asynchronously.
  Future<Either<Failure, Unit>> _loadFromFile() async {
    if (_loaded) return Right(unit);
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final ids = jsonData['ids'] as Map<String, dynamic>? ?? {};
        _data = {
          'ids': ids.map((key, value) {
            final codes = value as List<dynamic>;
            return MapEntry(key, codes.map((e) => e.toString()).toSet());
          }),
        };
      }
      _loaded = true;
      return Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to load data: $e'));
    }
  }

  /// Saves the current data to the JSON file asynchronously.
  Future<Either<Failure, Unit>> _saveToFile() async {
    try {
      final file = File(filePath);
      final ids = (_data['ids'] as Map<String, Set<String>>).map(
        (key, value) => MapEntry(key, value.toList()),
      );
      final jsonData = {'ids': ids};
      final jsonString = json.encode(jsonData);
      await file.writeAsString(jsonString);
      return Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to persist data: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> add({required Namespace namespace}) async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft()) return loadResult;

    final uriKey = namespace.uri.toString();
    final codes = (_data['ids'] as Map<String, Set<String>>).putIfAbsent(
      uriKey,
      () => {},
    );
    if (codes.contains(namespace.prefix)) {
      return Left(DuplicateIdFailure(namespace.prefix, namespace.uri));
    }
    codes.add(namespace.prefix);

    return await _saveToFile();
  }

  @override
  Future<Either<Failure, Unit>> remove({required Namespace namespace}) async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft()) return loadResult;

    (_data['ids'] as Map<String, Set<String>>)[namespace.uri.toString()]
        ?.remove(namespace.prefix);
    return await _saveToFile();
  }

  @override
  Future<Either<Failure, bool>> contains({required Namespace namespace}) async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft())
      return Left(
        loadResult.getLeft().getOrElse(() => StorageFailure('Unknown error')),
      );

    return Right(
      (_data['ids'] as Map<String, Set<String>>)[namespace.uri.toString()]
              ?.contains(namespace.prefix) ??
          false,
    );
  }

  @override
  Future<Either<Failure, Set<String>>> getAllUris() async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft())
      return Left(
        loadResult.getLeft().getOrElse(() => StorageFailure('Unknown error')),
      );

    return Right(Set.from((_data['ids'] as Map<String, Set<String>>).keys));
  }

  @override
  Future<Either<Failure, Set<String>>> getIdCodesForUri(Uri uri) async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft())
      return Left(
        loadResult.getLeft().getOrElse(() => StorageFailure('Unknown error')),
      );

    return Right(
      (_data['ids'] as Map<String, Set<String>>)[uri.toString()] ?? {},
    );
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft()) return loadResult;

    (_data['ids'] as Map<String, Set<String>>).clear();
    return await _saveToFile();
  }
}
