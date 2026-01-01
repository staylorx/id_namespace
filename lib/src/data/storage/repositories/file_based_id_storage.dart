import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../domain/storage/repositories/storage.dart';
import '../../../utils/failures.dart';
import '../../../data/core/models/namespace_dto.dart';

/// File-based implementation of AsyncIdStorage that persists data to JSON files asynchronously.
///
/// This implementation demonstrates how to create a persistent async storage layer
/// that saves and loads data from a JSON file on disk using async I/O.
class FileBasedIdStorage implements IdStorage {
  final String filePath;
  Set<NamespaceDto> _data = {};
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
        final namespaces = jsonData['namespaces'] as List<dynamic>? ?? [];
        _data = namespaces
            .map((e) => NamespaceDto.fromJson(e as Map<String, dynamic>))
            .toSet();
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
      final jsonData = {
        'namespaces': _data.map((dto) => dto.toJson()).toList(),
      };
      final jsonString = json.encode(jsonData);
      await file.writeAsString(jsonString);
      return Right(unit);
    } catch (e) {
      return Left(StorageFailure('Failed to persist data: $e'));
    }
  }

  /// Adds the namespace DTO to the storage.
  @override
  Future<Either<Failure, Unit>> add(NamespaceDto dto) async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft()) return loadResult;

    if (_data.contains(dto)) {
      return Left(
        DuplicateIdFailure(prefix: dto.prefix, uri: Uri.parse(dto.uri)),
      );
    }
    _data.add(dto);

    return await _saveToFile();
  }

  /// Removes the namespace DTO from the storage.
  @override
  Future<Either<Failure, Unit>> remove(NamespaceDto dto) async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft()) return loadResult;

    _data.remove(dto);
    return await _saveToFile();
  }

  /// Checks if the namespace DTO exists in the storage.
  @override
  Future<Either<Failure, bool>> contains(NamespaceDto dto) async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft()) {
      return Left(
        loadResult.getLeft().getOrElse(() => StorageFailure('Unknown error')),
      );
    }

    return Right(_data.contains(dto));
  }

  /// Returns all stored namespace DTOs.
  @override
  Future<Either<Failure, Set<NamespaceDto>>> getAll() async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft()) {
      return Left(
        loadResult.getLeft().getOrElse(() => StorageFailure('Unknown error')),
      );
    }

    return Right(Set.from(_data));
  }

  /// Clears all data from the storage.
  @override
  Future<Either<Failure, Unit>> clear() async {
    final loadResult = await _loadFromFile();
    if (loadResult.isLeft()) return loadResult;

    _data.clear();
    return await _saveToFile();
  }
}
