import 'dart:io';

import 'package:logging/logging.dart';

/// Utility class for centralized logging configuration and logger creation.
class Logging {
  static bool _configured = false;

  /// Gets a logger with the specified name.
  static Logger getLogger(String name) => Logger(name);

  /// Configures the root logger level and listener based on environment variable.
  ///
  /// This should be called once, typically on registry instantiation.
  /// Subsequent calls are ignored.
  static void configure() {
    if (_configured) return;
    _configured = true;

    final levelStr = Platform.environment['LOG_LEVEL'] ?? 'INFO';
    final level = _parseLevel(levelStr);

    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      // Simple console output, can be customized
      stdout.writeln(
        '${record.level.name}: ${record.loggerName}: ${record.time}: ${record.message}',
      );
    });
  }

  /// Parses a string level to a Level enum.
  static Level _parseLevel(String levelStr) {
    switch (levelStr.toUpperCase()) {
      case 'ALL':
        return Level.ALL;
      case 'FINEST':
        return Level.FINEST;
      case 'FINER':
        return Level.FINER;
      case 'FINE':
        return Level.FINE;
      case 'CONFIG':
        return Level.CONFIG;
      case 'INFO':
        return Level.INFO;
      case 'WARNING':
        return Level.WARNING;
      case 'SEVERE':
        return Level.SEVERE;
      case 'SHOUT':
        return Level.SHOUT;
      case 'OFF':
        return Level.OFF;
      default:
        return Level.INFO;
    }
  }
}
