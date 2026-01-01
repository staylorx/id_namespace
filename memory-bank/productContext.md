# Product Context

## Overview

The `id_namespace` package is a Dart library designed for managing ID namespaces with comprehensive RDF (Resource Description Framework) support. It provides a robust registry system for namespaces, enabling efficient management of RDF ontologies and prefixes in Dart and Flutter applications. The library is built using clean architecture principles to ensure maintainability, testability, and scalability.

## Key Features

- **Namespace Management**: Core functionality for adding, removing, and querying namespaces by prefix or URI
- **Ontology Loading**: Automatic fetching and registration of ontologies from remote URLs or local files
- **RDF Support**: Parsing and storage of RDF graphs in multiple formats (RDF/XML, Turtle, JSON-LD, N-Triples)
- **Multiple Storage Options**: Flexible storage implementations including in-memory, file-based, and caching storage
- **Clean Architecture**: Strict separation of domain, data, and presentation layers
- **Functional Programming**: Utilizes `fpdart` for error handling and functional constructs
- **Comprehensive Testing**: High test coverage with both unit and integration tests (currently 71% coverage)

## Architecture

The project follows Clean Architecture with three distinct layers:

- **Domain Layer**: Contains core business logic, entities, use cases, repositories, and services
- **Data Layer**: Implements domain interfaces with concrete repository and service implementations
- **Presentation Layer**: Provides the public API for consumers

## Target Audience

- Dart and Flutter developers working with RDF data
- Applications requiring namespace management for semantic web technologies
- Projects needing robust ontology handling and RDF parsing

## Current Version

v1.0.1 - Published on pub.dev with comprehensive documentation and examples.

## Repository

Hosted on GitHub at https://github.com/staylorx/id_namespace

## Related Documentation

- Current development status: [activeContext.md](activeContext.md)
- Architectural decisions: [decisionLog.md](decisionLog.md)
- System patterns: [systemPatterns.md](systemPatterns.md)