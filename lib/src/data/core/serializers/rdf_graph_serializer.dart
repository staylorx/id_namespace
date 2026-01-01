import 'package:rdf_core/rdf_core.dart';

/// Serializer for RdfGraph objects using Turtle format.
///
/// This class provides methods to serialize RdfGraph to String and deserialize String to RdfGraph,
/// handling null cases gracefully.
///
/// TODO: this seems to duplicate functionality; not worth it. Consider removing later.
class RdfGraphSerializer {
  /// Serializes an RdfGraph to a Turtle-formatted String.
  ///
  /// Returns null if the graph is null or serialization fails.
  static String? serialize(RdfGraph? graph) {
    if (graph == null) return null;

    try {
      return rdf.encode(graph, contentType: 'text/turtle');
    } catch (e) {
      // Return null on serialization failure
      return null;
    }
  }

  /// Deserializes a Turtle-formatted String to an RdfGraph.
  ///
  /// Returns null if the data is null or deserialization fails.
  static RdfGraph? deserialize(String? data) {
    if (data == null) return null;

    try {
      return rdf.decode(data, contentType: 'text/turtle');
    } catch (e) {
      // Return null on deserialization failure
      return null;
    }
  }
}
