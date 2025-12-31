import 'package:equatable/equatable.dart';

/// Base class for all failures in the domain layer.
abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

/// Failure when validation of an idCode fails for its uri.
class ValidationFailure extends Failure {
  final String message;

  const ValidationFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure when trying to register a prefix that already exists.
class DuplicateIdFailure extends Failure {
  final String prefix;
  final Uri uri;

  const DuplicateIdFailure(this.prefix, this.uri);

  @override
  List<Object?> get props => [prefix, uri];
}

/// Failure for storage-related errors.
class StorageFailure extends Failure {
  final String message;

  const StorageFailure(this.message);

  @override
  List<Object?> get props => [message];
}
