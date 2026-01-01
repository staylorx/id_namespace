# Decision Log

This file records architectural and implementation decisions...

*
[2026-01-01 00:39:36] - Refactored RdfGraphSerializer into NamespaceDto to eliminate duplication and align with clean architecture principles. Moved RDF serialization/deserialization logic directly into the DTO as private static methods, removing the separate serializer class.

[2026-01-01 00:43:02] - Removed duplicate RdfGraphSerializer class from lib/src/data/core/serializers/rdf_graph_serializer.dart. The serializer duplicated functionality already present as private methods in NamespaceDto and was unused throughout the codebase. This eliminates dead code and maintains clean architecture by keeping serialization logic encapsulated within the DTO where it's used.

## Architecture Refactoring

[2026-01-01 01:35:25] - Refactored fetchAndRegisterOntology to separate concerns: created FetchContentService and RdfParsingService interfaces in domain, implemented in data layer, updated usecase to orchestrate steps, removed monolithic method from repository. This improves testability and reusability.
