/// Data layer implementations for the id_namespace library.
///
/// Contains concrete implementations of repositories, services, and data models
/// following the clean architecture pattern.
library;

export 'core/models/namespace_dto.dart';
export 'core/repositories/id_registry_repository_impl.dart';
export 'core/services/fetch_content_service_impl.dart';
export 'core/services/rdf_parsing_service_impl.dart';
export 'storage/repositories/caching_storage.dart';
export 'storage/repositories/file_based_id_storage.dart';
export 'storage/repositories/in_memory_id_storage.dart';
