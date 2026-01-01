# ID Namespace Registry

A Dart package for managing ID namespaces with RDF support, designed using clean architecture principles. This library provides a robust registry system for namespaces, enabling efficient management of RDF ontologies and prefixes in Dart and Flutter applications.

## Features

- **Namespace Management**: Add, remove, and query namespaces by prefix or URI
- **Ontology Loading**: Fetch and register ontologies from URLs or local files
- **RDF Support**: Parse and store RDF graphs from various formats
- **Multiple Storage Options**: In-memory, file-based, and caching storage implementations
- **Clean Architecture**: Separated domain, data, and presentation layers for maintainability
- **Functional Programming**: Uses `fpdart` for error handling and functional constructs
- **Comprehensive Testing**: High test coverage with unit and integration tests

## Architecture

This library follows the Clean Architecture pattern, ensuring separation of concerns and testability:

### Domain Layer (`lib/src/domain/`)
Contains the core business logic and entities:
- **Entities**: `NamespaceRegistry`, `Namespace` - Core data models
- **Use Cases**: Business logic operations like `AddNamespaceUsecase`, `FetchAndRegisterOntologyUsecase`
- **Repositories**: Abstract interfaces for data access (`IdRegistryRepository`, `Storage`)
- **Services**: Domain services for fetching content and parsing RDF
- **Value Objects**: Immutable objects like `Namespace`

### Data Layer (`lib/src/data/`)
Implements the domain interfaces:
- **Repository Implementations**: `IdRegistryRepositoryImpl`
- **Service Implementations**: `FetchContentServiceImpl`, `RdfParsingServiceImpl`
- **Storage Implementations**: `InMemoryIdStorage`, `FileBasedIdStorage`, `CachingStorage`
- **Data Transfer Objects**: `NamespaceDto` for data serialization

### Presentation Layer
The exported API provides a clean interface for consumers:
- Direct access to domain entities, use cases, and repositories
- Utility classes for logging and error handling

## Installation

Add `id_namespace` to your `pubspec.yaml`:

```yaml
dependencies:
  id_namespace: ^1.0.1
```

Then run:

```bash
flutter pub get
# or
dart pub get
```

## Usage

### Basic Namespace Management

```dart
import 'package:id_namespace/id_namespace.dart';

// Create storage (choose one)
final storage = InMemoryIdStorage(); // For temporary storage
// or
final storage = FileBasedIdStorage(filePath: 'namespaces.json'); // For persistent storage

// Create repository and use cases
final repository = IdRegistryRepositoryImpl(storage: storage);
final addUsecase = AddNamespaceUsecase(repository: repository);
final getAllUsecase = GetAllNamespacesUsecase(repository: repository);

// Add a namespace
final namespace = Namespace(
  uri: Uri.parse('http://example.com/ns#'),
  prefix: 'ex',
  description: 'Example namespace',
);

final result = await addUsecase.execute(namespace: namespace);
result.fold(
  (failure) => print('Error: $failure'),
  (_) => print('Namespace added successfully'),
);

// Get all namespaces
final allResult = await getAllUsecase.execute();
allResult.fold(
  (failure) => print('Error: $failure'),
  (namespaces) => print('Registered namespaces: ${namespaces.length}'),
);
```

### Loading Ontologies

```dart
import 'package:id_namespace/id_namespace.dart';

// Set up services
final fetchService = FetchContentServiceImpl();
final rdfService = RdfParsingServiceImpl();
final repository = IdRegistryRepositoryImpl(storage: storage);

// Create ontology loading use case
final fetchOntologyUsecase = FetchAndRegisterOntologyUsecase(
  fetchContentService: fetchService,
  rdfParsingService: rdfService,
  repository: repository,
);

// Load an ontology from URL
final ontologyResult = await fetchOntologyUsecase.execute(
  url: 'https://www.w3.org/1999/02/22-rdf-syntax-ns',
  prefix: 'rdf',
  description: 'RDF Vocabulary',
);

ontologyResult.fold(
  (failure) => print('Failed to load ontology: $failure'),
  (_) => print('Ontology loaded and registered'),
);
```

### Querying Namespaces

```dart
import 'package:id_namespace/id_namespace.dart';

// Get namespace by prefix
final getByPrefixUsecase = GetNamespaceByPrefixUsecase(repository: repository);
final prefixResult = await getByPrefixUsecase.execute(prefix: 'rdf');
prefixResult.fold(
  (failure) => print('Namespace not found'),
  (namespace) => print('Found: ${namespace.uri}'),
);

// Get namespace by URI
final getByUriUsecase = GetNamespaceByUriUsecase(repository: repository);
final uriResult = await getByUriUsecase.execute(uri: Uri.parse('http://example.com/ns#'));
uriResult.fold(
  (failure) => print('Namespace not found'),
  (namespace) => print('Found: ${namespace.prefix}'),
);

// Check if registered
final isRegisteredUsecase = IsRegisteredUsecase(repository: repository);
final isRegistered = await isRegisteredUsecase.execute(namespace: someNamespace);
```

## Supported Ontology Formats

The library supports parsing ontologies in multiple RDF formats:

- **RDF/XML** (`.rdf`) - Standard XML-based RDF format
- **Turtle** (`.ttl`) - Compact, human-readable format
- **JSON-LD** (`.jsonld`) - JSON-based linked data format
- **N-Triples** (`.nt`) - Line-based triple format

## API Reference

### Core Classes

- [`Namespace`](lib/src/domain/core/value_objects/namespace.dart) - Represents a namespace with URI, prefix, and optional RDF graph
- [`NamespaceRegistry`](lib/src/domain/core/entities/namespace_registry.dart) - Container for registered namespaces

### Use Cases

- `AddNamespaceUsecase` - Add a new namespace to the registry
- `RemoveNamespaceUsecase` - Remove a namespace by prefix
- `GetAllNamespacesUsecase` - Retrieve all registered namespaces
- `GetNamespaceByPrefixUsecase` - Find namespace by prefix
- `GetNamespaceByUriUsecase` - Find namespace by URI
- `IsRegisteredUsecase` - Check if a namespace is registered
- `FetchAndRegisterOntologyUsecase` - Load and register an ontology
- `ClearRegistryUsecase` - Clear all namespaces

### Storage Implementations

- `InMemoryIdStorage` - Temporary storage in memory
- `FileBasedIdStorage` - Persistent JSON file storage
- `CachingStorage` - Cached wrapper around another storage

### Services

- `FetchContentService` - Fetch content from URLs or files
- `RdfParsingService` - Parse RDF content into graphs

## Error Handling

The library uses functional programming principles with `Either<Failure, Result>` for error handling. Common failure types include:

- `NetworkFailure` - Issues fetching remote content
- `ParsingFailure` - RDF parsing errors
- `StorageFailure` - Storage operation errors
- `ValidationFailure` - Invalid input data

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Repository

- [GitHub Repository](https://github.com/staylorx/id_namespace)
- [Issue Tracker](https://github.com/staylorx/id_namespace/issues)
- [Documentation](https://github.com/staylorx/id_namespace)
