import 'package:equatable/equatable.dart';

import '../../../domain/core/value_objects/namespace.dart';
import '../serializers/rdf_graph_serializer.dart';

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
      rdfGraph: RdfGraphSerializer.deserialize(rdfGraph),
    );
  }

  /// Creates a NamespaceDto from a domain Namespace entity.
  factory NamespaceDto.fromEntity(Namespace namespace) {
    return NamespaceDto(
      uri: namespace.uri.toString(),
      prefix: namespace.prefix,
      description: namespace.description,
      rdfGraph: RdfGraphSerializer.serialize(namespace.rdfGraph),
    );
  }
}
