# System Patterns

This file documents the recurring architectural and implementation patterns used throughout the `id_namespace` project.

## Architectural Patterns

### Clean Architecture Layers
- **Domain Layer**: Contains business logic, entities, value objects, use cases, repositories (interfaces), and services (interfaces). No external dependencies.
- **Data Layer**: Implements domain interfaces with concrete classes. Handles data persistence, external API calls, and serialization.
- **Presentation Layer**: Provides the public API and exports domain entities for consumers.

### Repository Pattern
- Abstract data access through repository interfaces in the domain layer
- Multiple implementations (in-memory, file-based, caching) in the data layer
- Domain logic remains agnostic to storage details

### Use Case Pattern
- Business operations encapsulated in use case classes
- Each use case has a single responsibility and orchestrates domain logic
- Dependencies injected via constructor for testability

## Implementation Patterns

### Error Handling with Either
- All operations return `Either<Failure, Result>` from fpdart
- Failures are custom classes extending base `Failure` type
- No exceptions thrown; errors handled functionally

### Dependency Injection
- All use cases and services receive dependencies through constructors
- No global state or singletons in domain/data layers
- Enables easy mocking for unit tests

### Functional Programming Constructs
- Use of `fpdart` for Either, Option, and other functional types
- Immutable data structures where possible
- Composition over inheritance

## Coding Standards

### Naming Conventions
- Always use named parameters in function calls for clarity
- Class names follow PascalCase
- Method names follow camelCase
- Private members prefixed with underscore

### Documentation
- All public methods have dartdoc comments
- Comments explain purpose, parameters, and return values
- API reference links in README

### Testing Patterns
- **Unit Tests**: Test individual classes in isolation with mocked dependencies
- **Integration Tests**: Test full workflows with real implementations
- Test files mirror source structure in `test/unit/` and `test/integration/`
- High coverage target with edge cases covered

## File Organization
- `lib/src/domain/`: Domain layer code
- `lib/src/data/`: Data layer implementations
- `lib/src/utils/`: Shared utilities (logging, failures)
- `test/unit/`: Unit tests
- `test/integration/`: Integration tests
- `test/assets/`: Test data files

## RDF Processing Patterns
- Separation of content fetching and RDF parsing into distinct services
- Support for multiple RDF formats with extensible parser
- RDF graphs stored as part of namespace entities

## Related Documentation

- Architectural decisions behind these patterns: [decisionLog.md](decisionLog.md)