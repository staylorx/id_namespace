# Decision Log

This file records architectural and implementation decisions...

*
[2026-01-01 00:39:36] - Refactored RdfGraphSerializer into NamespaceDto to eliminate duplication and align with clean architecture principles. Moved RDF serialization/deserialization logic directly into the DTO as private static methods, removing the separate serializer class.

[2026-01-01 00:43:02] - Removed duplicate RdfGraphSerializer class from lib/src/data/core/serializers/rdf_graph_serializer.dart. The serializer duplicated functionality already present as private methods in NamespaceDto and was unused throughout the codebase. This eliminates dead code and maintains clean architecture by keeping serialization logic encapsulated within the DTO where it's used.

## Architecture Refactoring

[2026-01-01 01:35:25] - Refactored fetchAndRegisterOntology to separate concerns: created FetchContentService and RdfParsingService interfaces in domain, implemented in data layer, updated usecase to orchestrate steps, removed monolithic method from repository. This improves testability and reusability.

## Architectural Decisions

[2026-01-01 05:06:50] - Adopted Clean Architecture pattern with strict separation of domain, data, and presentation layers. Domain layer contains only business logic and abstractions, data layer implements interfaces, presentation layer provides public API. This ensures testability, maintainability, and independence from external frameworks.

[2026-01-01 05:06:50] - Implemented functional programming with fpdart library for error handling using Either<Failure, Result> pattern. This provides type-safe error handling without exceptions, improving code reliability and composability.

[2026-01-01 05:06:50] - Established dependency injection pattern for use cases, requiring all dependencies to be injected through constructors. This maintains clean architecture principles and enables easy testing with mocks.

[2026-01-01 05:06:50] - Designed storage abstraction with repository pattern, allowing multiple storage implementations (in-memory, file-based, caching) while keeping domain layer agnostic to storage details.

[2026-01-01 05:06:50] - Chose comprehensive testing strategy with both unit and integration tests, targeting high coverage to ensure reliability. All public APIs and edge cases are tested, with integration tests covering full workflows.

## Related Documentation

- Implemented patterns from these decisions: [systemPatterns.md](systemPatterns.md)

## Architectural Rule Application

[2026-01-01 20:15:20] - Applied the architectural rule "Pure business rules: sync where possible. Anything that talks to the outside world: async at the boundary."

Analysis showed that RDF parsing was unnecessarily async despite being pure synchronous business logic. Refactored RdfParsingService to return Either instead of Future<Either>, updated implementation and tests accordingly. All 103 tests pass, maintaining clean architecture principles.

[2026-10-11] - Removed empty directory lib/src/data/storage/models/ (residue, not intentional). The package's storage models live in lib/src/data/core/models/ (see data.dart exports and the repositories' imports); storage/ only holds repositories/, and the canonical models location is core/models, not storage/models. The directory was empty, unreferenced by any import/config, and would be deleted by a scoped clean - its removal is a deliberate no-op that records the intent that no storage/models/ tree is expected. See kanban task t_c630641e.
