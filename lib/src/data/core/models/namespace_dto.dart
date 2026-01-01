import 'package:equatable/equatable.dart';
import 'package:rdf_core/rdf_core.dart';

import '../../../domain/core/value_objects/namespace.dart';

/// Data Transfer Object for Namespace entity, used for serialization and storage.
///
/// This DTO provides methods to convert between the domain Namespace entity
/// and a JSON-serializable format suitable for data persistence.
class NamespaceDto with EquatableMixin {
  final String uri;
  final String prefix;
  final String? description;
  final String? rdfGraph;

  const NamespaceDto({
    required this.uri,
    required this.prefix,
    this.description,
    this.rdfGraph,
  });

  @override
  List<Object?> get props => [uri, prefix];

  /// Creates a NamespaceDto from a JSON map.
  factory NamespaceDto.fromJson(Map<String, dynamic> json) {
    return NamespaceDto(
      uri: json['uri'] as String,
      prefix: json['prefix'] as String,
      description: json['description'] as String?,
      rdfGraph: json['rdfGraph'] as String?,
    );
  }

  /// Converts the NamespaceDto to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'uri': uri,
      'prefix': prefix,
      'description': description,
      'rdfGraph': rdfGraph,
    };
  }

  /// Converts the NamespaceDto to a domain Namespace entity.
  Namespace toEntity() {
    return Namespace(
      uri: Uri.parse(uri),
      prefix: prefix,
      description: description,
      rdfGraph: _deserializeRdfGraph(rdfGraph),
    );
  }

  /// Creates a NamespaceDto from a domain Namespace entity.
  factory NamespaceDto.fromEntity(Namespace namespace) {
    return NamespaceDto(
      uri: namespace.uri.toString(),
      prefix: namespace.prefix,
      description: namespace.description,
      rdfGraph: _serializeRdfGraph(namespace.rdfGraph),
    );
  }

  /// Deserializes a Turtle-formatted String to an RdfGraph.
  ///
  /// Returns null if the data is null or deserialization fails.
  static RdfGraph? _deserializeRdfGraph(String? data) {
    if (data == null) return null;

    try {
      return rdf.decode(data, contentType: 'text/turtle');
    } catch (e) {
      // Return null on deserialization failure
      return null;
    }
  }

  /// Serializes an RdfGraph to a Turtle-formatted String.
  ///
  /// Returns null if the graph is null or serialization fails.
  static String? _serializeRdfGraph(RdfGraph? graph) {
    if (graph == null) return null;

    try {
      return rdf.encode(graph, contentType: 'text/turtle');
    } catch (e) {
      // Return null on serialization failure
      return null;
    }
  }
}
