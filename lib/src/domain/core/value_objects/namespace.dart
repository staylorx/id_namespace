import 'package:equatable/equatable.dart';
import 'package:rdf_core/rdf_core.dart';

/// Represents a namespace with a URI, prefix, optional description, and RDF graph.
class Namespace with EquatableMixin {
  final Uri uri;
  final String prefix;
  final String? description;
  final RdfGraph? rdfGraph;

  const Namespace({
    required this.uri,
    required this.prefix,
    this.description,
    this.rdfGraph,
  });

  /// Creates a copy of this namespace with optionally updated fields.
  Namespace copyWith({
    Uri? uri,
    String? prefix,
    String? description,
    RdfGraph? rdfGraph,
  }) {
    return Namespace(
      uri: uri ?? this.uri,
      prefix: prefix ?? this.prefix,
      description: description ?? this.description,
      rdfGraph: rdfGraph ?? this.rdfGraph,
    );
  }

  @override
  List<Object?> get props => [prefix];
}
