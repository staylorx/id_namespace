import 'package:equatable/equatable.dart';
import 'package:rdf_core/rdf_core.dart';
import 'package:rdf_xml/rdf_xml.dart';

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
  List<Object?> get props => [prefix];

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
      rdfGraph: deserialize(rdfGraph),
    );
  }

  /// Creates a NamespaceDto from a domain Namespace entity.
  factory NamespaceDto.fromEntity(Namespace namespace) {
    return NamespaceDto(
      uri: namespace.uri.toString(),
      prefix: namespace.prefix,
      description: namespace.description,
      rdfGraph: serialize(namespace.rdfGraph),
    );
  }

  /// Serializes an [RdfGraph] to a Turtle string.
  ///
  /// Returns null if [graph] is null.
  /// Returns null if serialization fails.
  static String? serialize(RdfGraph? graph) {
    if (graph == null) return null;
    try {
      return rdf.encode(graph, contentType: 'text/turtle');
    } catch (e) {
      return null;
    }
  }

  /// Deserializes a Turtle string to an [RdfGraph].
  ///
  /// Returns null if [rdfString] is null or empty.
  /// Returns null if deserialization fails.
  static RdfGraph? deserialize(String? rdfString) {
    if (rdfString == null || rdfString.isEmpty) return null;
    try {
      return rdf.decode(rdfString, contentType: 'text/turtle');
    } catch (e) {
      return null;
    }
  }

  /// Determines RDF format from URL path.
  static String getFormatFromUrl(String path) {
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

  /// Parses RDF content into an [RdfGraph].
  static RdfGraph parseRdfContent(String content, String format) {
    switch (format) {
      case 'rdfxml':
        return rdfxml.decode(content);
      default:
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
          default:
            contentType = 'text/turtle'; // default to turtle
        }
        return rdf.decode(content, contentType: contentType);
    }
  }
}
