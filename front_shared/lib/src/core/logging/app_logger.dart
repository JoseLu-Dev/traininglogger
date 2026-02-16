import 'package:logger/logger.dart';
import 'log_service.dart';

/// App logger with class context
///
/// Log levels:
/// - ERROR: Unexpected exceptions, system failures, crashes
/// - WARN: Recoverable issues, deprecated features
/// - INFO: State-changing operations ONLY (create, update, delete data), validation failures
/// - DEBUG: Read operations, detailed flow, navigation events
class AppLogger {
  final String _className;
  Logger? _logger;

  AppLogger.forClass(Type type) : _className = type.toString();

  Future<Logger> get _log async {
    _logger ??= await LogService.instance;
    return _logger!;
  }

  void debug(String message) {
    _log.then((logger) => logger.d('[$_className] $message'));
  }

  void info(String message) {
    _log.then((logger) => logger.i('[$_className] $message'));
  }

  void warning(String message, [dynamic error]) {
    _log.then((logger) => logger.w('[$_className] $message', error: error));
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log.then(
      (logger) => logger.e(
        '[$_className] $message',
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }
}
