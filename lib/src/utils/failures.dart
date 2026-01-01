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

  const DuplicateIdFailure({required this.prefix, required this.uri});

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

/// Failure for network-related errors.
class NetworkFailure extends Failure {
  final String message;

  const NetworkFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure for RDF parsing errors.
class ParseFailure extends Failure {
  final String message;

  const ParseFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure when a namespace is not found.
class NotFoundFailure extends Failure {
  final String message;

  const NotFoundFailure(this.message);

  @override
  List<Object?> get props => [message];
}
