import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

/// Compact log printer that outputs single-line logs for debug/info/warning
/// and full stack traces for errors
class CompactLogPrinter extends LogPrinter {
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  @override
  List<String> log(LogEvent event) {
    final timestamp = _dateFormat.format(event.time);
    final level = _getLevelString(event.level);
    final message = event.message;

    final lines = <String>[];

    // First line is always: [timestamp] LEVEL message
    lines.add('[$timestamp] $level $message');

    // For errors, add the error details and complete stack trace
    if (event.level == Level.error && (event.error != null || event.stackTrace != null)) {
      if (event.error != null) {
        lines.add('Error: ${event.error}');
      }
      if (event.stackTrace != null) {
        lines.add(event.stackTrace.toString());
      }
    }

    return lines;
  }

  String _getLevelString(Level level) {
    switch (level) {
      case Level.debug:
        return 'DEBUG';
      case Level.info:
        return 'INFO ';
      case Level.warning:
        return 'WARN ';
      case Level.error:
        return 'ERROR';
      case Level.trace:
        return 'TRACE';
      case Level.fatal:
        return 'FATAL';
      default:
        return level.toString();
    }
  }
}
