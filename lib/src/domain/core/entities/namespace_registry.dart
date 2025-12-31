import 'package:equatable/equatable.dart';
import 'package:id_namespace/src/domain/core/value_objects/namespace.dart';

/// A registry holding namespaces mapped by their prefixes.
class NamespaceRegistry with EquatableMixin {
  final Map<String, Namespace> registry;

  NamespaceRegistry({required this.registry});

  @override
  List<Object?> get props => [registry];
}
