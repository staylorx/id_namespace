import 'package:equatable/equatable.dart';
import 'package:rdf_core/rdf_core.dart';

class Namespace with EquatableMixin {
  final Uri uri;
  final String prefix;
  final String idCode;
  final String? description;
  final RdfGraph? rdfGraph;

  const Namespace({
    required this.uri,
    required this.prefix,
    required this.idCode,
    this.description,
    this.rdfGraph,
  });

  Namespace copyWith({
    Uri? uri,
    String? prefix,
    String? idCode,
    String? description,
    RdfGraph? rdfGraph,
  }) {
    return Namespace(
      uri: uri ?? this.uri,
      prefix: prefix ?? this.prefix,
      idCode: idCode ?? this.idCode,
      description: description ?? this.description,
      rdfGraph: rdfGraph ?? this.rdfGraph,
    );
  }

  @override
  List<Object?> get props => [uri];
}
