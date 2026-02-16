import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:front_shared/src/core/logging/compact_log_printer.dart';

void main() {
  group('CompactLogPrinter', () {
    late CompactLogPrinter printer;

    setUp(() {
      printer = CompactLogPrinter();
    });

    test('debug log should be single line with timestamp, level, and message', () {
      final event = LogEvent(
        Level.debug,
        'Test debug message',
        time: DateTime(2026, 2, 16, 14, 30, 45),
      );

      final output = printer.log(event);

      expect(output.length, 1);
      expect(output[0], contains('[2026-02-16 14:30:45]'));
      expect(output[0], contains('DEBUG'));
      expect(output[0], contains('Test debug message'));
    });

    test('info log should be single line with timestamp, level, and message', () {
      final event = LogEvent(
        Level.info,
        'Test info message',
        time: DateTime(2026, 2, 16, 14, 30, 45),
      );

      final output = printer.log(event);

      expect(output.length, 1);
      expect(output[0], contains('[2026-02-16 14:30:45]'));
      expect(output[0], contains('INFO'));
      expect(output[0], contains('Test info message'));
    });

    test('warning log should be single line with timestamp, level, and message', () {
      final event = LogEvent(
        Level.warning,
        'Test warning message',
        time: DateTime(2026, 2, 16, 14, 30, 45),
      );

      final output = printer.log(event);

      expect(output.length, 1);
      expect(output[0], contains('[2026-02-16 14:30:45]'));
      expect(output[0], contains('WARN'));
      expect(output[0], contains('Test warning message'));
    });

    test('error log should have timestamp, level, message, and full stack trace', () {
      final exception = Exception('Test exception');
      final stackTrace = StackTrace.fromString('''
#0      TestClass.testMethod (package:test/test.dart:10:5)
#1      main (package:test/test.dart:5:3)
''');

      final event = LogEvent(
        Level.error,
        'Test error message',
        error: exception,
        stackTrace: stackTrace,
        time: DateTime(2026, 2, 16, 14, 30, 45),
      );

      final output = printer.log(event);

      // Should have multiple lines: first line + error + stack trace
      expect(output.length, greaterThan(1));

      // First line should have timestamp, level, and message
      expect(output[0], contains('[2026-02-16 14:30:45]'));
      expect(output[0], contains('ERROR'));
      expect(output[0], contains('Test error message'));

      // Should contain error details
      expect(output.join('\n'), contains('Error: Exception: Test exception'));

      // Should contain complete stack trace
      expect(output.join('\n'), contains('TestClass.testMethod'));
      expect(output.join('\n'), contains('package:test/test.dart:10:5'));
    });

    test('error log without stack trace should still have timestamp and level', () {
      final event = LogEvent(
        Level.error,
        'Test error message',
        time: DateTime(2026, 2, 16, 14, 30, 45),
      );

      final output = printer.log(event);

      expect(output.length, 1);
      expect(output[0], contains('[2026-02-16 14:30:45]'));
      expect(output[0], contains('ERROR'));
      expect(output[0], contains('Test error message'));
    });
  });
}
