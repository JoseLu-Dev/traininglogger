import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';
import 'compact_log_printer.dart';

class LogService {
  static Logger? _instance;
  static String? _currentDate;
  static String? _userId;
  static String? _appIdentifier;

  /// Configure LogService with app identifier ('athlete' or 'coach')
  /// Must be called in main() before using any logging
  static void configure(String appIdentifier) {
    _appIdentifier = appIdentifier;
  }

  static Future<Logger> get instance async {
    if (_appIdentifier == null) {
      throw StateError(
        'LogService not configured. Call LogService.configure("athlete"|"coach") in main() before using logging.'
      );
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Rotate log file if new day
    if (_instance == null || _currentDate != today) {
      _currentDate = today;
      _instance = await _createLogger();
    }

    return _instance!;
  }

  static Future<Logger> _createLogger() async {
    final logFile = await _getDailyLogFile();

    return Logger(
      filter: ProductionFilter(),
      printer: CompactLogPrinter(),
      output: MultiOutput([
        ConsoleOutput(),
        _FileOutput(file: logFile),
      ]),
    );
  }

  static Future<File> _getDailyLogFile() async {
    // Store logs in same directory as database, under /logs subdirectory
    final dbFolder = await getApplicationDocumentsDirectory();
    final logsDir = Directory(p.join(dbFolder.path, 'liftlogger-$_appIdentifier', 'logs'));
    await logsDir.create(recursive: true);

    final fileName = 'app_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.log';
    return File(p.join(logsDir.path, fileName));
  }

  static void setUserId(String userId) {
    _userId = userId;
  }

  static String? get userId => _userId;
}

class _FileOutput extends LogOutput {
  final File file;
  _FileOutput({required this.file});

  @override
  void output(OutputEvent event) {
    try {
      for (var line in event.lines) {
        file.writeAsStringSync('$line\n', mode: FileMode.append);
      }
    } catch (e) {
      // Silently fail - logs will still appear in console via ConsoleOutput
    }
  }
}
