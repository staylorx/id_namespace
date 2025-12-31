import '../../../domain/core/value_objects/namespace.dart';

/// Data Transfer Object for Namespace entity, used for serialization and storage.
///
/// This DTO provides methods to convert between the domain Namespace entity
/// and a JSON-serializable format suitable for data persistence.
class NamespaceDto {
  final String uri;
  final String prefix;
  final String? description;
  final Map<String, dynamic>? rdfGraph;

  const NamespaceDto({
    required this.uri,
    required this.prefix,
    this.description,
    this.rdfGraph,
  });

  /// Creates a NamespaceDto from a JSON map.
  factory NamespaceDto.fromJson(Map<String, dynamic> json) {
    return NamespaceDto(
      uri: json['uri'] as String,
      prefix: json['prefix'] as String,
      description: json['description'] as String?,
      rdfGraph: json['rdfGraph'] as Map<String, dynamic>?,
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
    // TODO: Implement proper RdfGraph serialization/deserialization based on rdf_core API
    return Namespace(
      uri: Uri.parse(uri),
      prefix: prefix,
      description: description,
      rdfGraph:
          null, // Temporarily set to null until RdfGraph serialization is implemented
    );
  }

  /// Creates a NamespaceDto from a domain Namespace entity.
  factory NamespaceDto.fromEntity(Namespace namespace) {
    // TODO: Implement proper RdfGraph serialization based on rdf_core API
    return NamespaceDto(
      uri: namespace.uri.toString(),
      prefix: namespace.prefix,
      description: namespace.description,
      rdfGraph:
          null, // Temporarily set to null until RdfGraph serialization is implemented
    );
  }
}
