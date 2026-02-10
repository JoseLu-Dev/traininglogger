import 'dart:io';
import 'package:mustache_template/mustache.dart';
import 'package:yaml/yaml.dart';
import 'package:recase/recase.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: fvm dart run tool/generate_entity.dart <entity_yaml_file>');
    print(
      'Example: fvm dart run tool/generate_entity.dart entities/training_plan.yaml',
    );
    exit(1);
  }

  final entityFile = args[0];
  final generator = EntityGenerator();

  try {
    generator.generate(entityFile);
    print('\u2705 Successfully generated entity from $entityFile');
  } catch (e, stackTrace) {
    print('\u274C Error generating entity: $e');
    print(stackTrace);
    exit(1);
  }
}

class EntityGenerator {
  void generate(String yamlPath) {
    // 1. Load and parse YAML
    final yamlContent = File(yamlPath).readAsStringSync();
    final yaml = loadYaml(yamlContent) as Map;

    // 2. Build template context
    final context = buildContext(yaml);

    // 3. Generate files
    generateFile(
      'domain_model.dart.mustache',
      context,
      'lib/src/generated/domain/models/${context['snakeName']}.dart',
    );
    generateFile(
      'table.dart.mustache',
      context,
      'lib/src/generated/data/local/database/tables/${context['snakeTableName']}_table.dart',
    );
    generateFile(
      'dao.dart.mustache',
      context,
      'lib/src/generated/data/local/database/daos/${context['snakeName']}_dao.dart',
    );
    generateFile(
      'repository.dart.mustache',
      context,
      'lib/src/generated/domain/repositories/${context['snakeName']}_repository.dart',
    );
    generateFile(
      'repository_impl.dart.mustache',
      context,
      'lib/src/generated/data/repositories/${context['snakeName']}_repository_impl.dart',
    );
    generateFile(
      'dao_test.dart.mustache',
      context,
      'test/generated/${context['snakeName']}_dao_test.dart',
    );
  }

  Map<String, dynamic> buildContext(Map yaml) {
    final entity = yaml['entity'] as Map;
    final fields = (yaml['fields'] as List).cast<Map>();
    final indexes = (yaml['indexes'] as List?)?.cast<Map>() ?? [];
    final queries = (yaml['queries'] as List?)?.cast<Map>() ?? [];
    final createFactory = yaml['createFactory'] as Map?;

    final name = entity['name'] as String;
    final tableName = entity['tableName'] as String;
    final rc = ReCase(name);
    final tableRc = ReCase(tableName);

    return {
      'name': name,
      'snakeName': rc.snakeCase,
      'camelName': rc.camelCase,
      'lowerName': name[0].toLowerCase() + name.substring(1),
      'tableName': tableName,
      'snakeTableName': tableRc.snakeCase,
      'pluralName': pluralize(name),
      'camelPluralName': ReCase(pluralize(name)).camelCase,
      'description': entity['description'],
      'fields': fields.map((f) => processField(f)).toList(),
      'indexes': indexes.map((i) => processIndex(i)).toList(),
      'hasIndexes': indexes.isNotEmpty,
      'queries': queries.map((q) => processQuery(q)).toList(),
      'createFactoryParams': createFactory != null
          ? processCreateFactory(createFactory, fields)
          : [],
      'enums': extractEnums(fields, rc.snakeCase),
      'references': extractReferences(fields),
    };
  }

  Map<String, dynamic> processField(Map field) {
    final type = field['type'] as String;
    final nullable = field['nullable'] as bool? ?? false;
    final hasDefault = field.containsKey('default');

    return {
      'name': field['name'],
      'type': type,
      'nullable': nullable,
      'hasDefault': hasDefault,
      'tableType': field['tableType'] ?? 'text()',
      'constraints': field['constraints'],
      'default': field['default'],
      'dartColumnType': getDartColumnType(type),
      'reference': field['reference'],
      'testValue': getTestValue(field),
    };
  }

  Map<String, dynamic> processIndex(Map index) {
    final columns = (index['columns'] as List).cast<String>();
    return {
      'name': index['name'],
      'columns': columns,
      'columnsWithComma': columns
          .asMap()
          .entries
          .map((e) => {
                'name': e.value,
                'last': e.key == columns.length - 1,
              })
          .toList(),
    };
  }

  Map<String, dynamic> processQuery(Map query) {
    final returns = query['returns'] as String;
    final isSingle = !returns.startsWith('List<');
    final params = (query['params'] as List?)?.cast<Map>() ?? [];

    // Convert Data return type to domain type
    String domainReturns = returns;
    if (returns.contains('Data')) {
      domainReturns = returns.replaceAll('Data', '');
    }

    return {
      'name': query['name'],
      'returns': returns,
      'domainReturns': domainReturns,
      'isSingle': isSingle,
      'params':
          params
              .map((p) => {'name': p['name'], 'type': p['type'], 'last': false})
              .toList()
            ..lastOrNull?['last'] = true,
      'where': query['where'],
      'orderBy': query['orderBy'],
    };
  }

  List<Map<String, dynamic>> processCreateFactory(
    Map factory,
    List<Map> allFields,
  ) {
    final paramNames = (factory['params'] as List).cast<String>();
    return paramNames.map((name) {
      final field = allFields.firstWhere((f) => f['name'] == name);
      final type = field['type'] as String;
      final nullable = field['nullable'] as bool? ?? false;

      return {
        'name': name,
        'type': type,
        'isRequired': !nullable && !field.containsKey('default'),
        'hasDefault': field.containsKey('default'),
        'default': field.containsKey('default')
            ? convertDriftDefaultToDart(field['default'].toString())
            : null,
        'testValue': getTestValue(field),
        'last': false,
      };
    }).toList()..lastOrNull?['last'] = true;
  }

  List<Map<String, dynamic>> extractEnums(
    List<Map> fields,
    String entitySnakeName,
  ) {
    final enums = <Map<String, dynamic>>[];
    final seenEnums = <String>{};
    for (final f in fields) {
      if (f.containsKey('enumValues')) {
        final enumType = f['type'] as String;
        if (!seenEnums.contains(enumType)) {
          seenEnums.add(enumType);
          final values = (f['enumValues'] as List).cast<String>();
          enums.add({
            'name': enumType,
            'entitySnakeName': entitySnakeName,
            'values': values
                .asMap()
                .entries
                .map((e) => {
                      'value': e.value,
                      'last': e.key == values.length - 1,
                    })
                .toList(),
          });
        }
      }
    }
    return enums;
  }

  List<Map<String, dynamic>> extractReferences(List<Map> fields) {
    final refs = <Map<String, dynamic>>[];
    for (final f in fields) {
      if (f.containsKey('reference')) {
        final ref = f['reference'] as Map;
        refs.add({
          'table': ref['table'],
          'snakeTable': ReCase(ref['table'] as String).snakeCase,
        });
      }
    }
    return refs;
  }

  void generateFile(
    String templateName,
    Map<String, dynamic> context,
    String outputPath,
  ) {
    final templateContent = File(
      'tool/templates/$templateName',
    ).readAsStringSync();
    final template = Template(templateContent, lenient: true);
    final output = template.renderString(context);

    final outputFile = File(outputPath);
    outputFile.createSync(recursive: true);
    outputFile.writeAsStringSync(output);

    print('  Generated: $outputPath');
  }

  String getDartColumnType(String dartType) {
    switch (dartType) {
      case 'String':
        return 'TextColumn';
      case 'int':
        return 'IntColumn';
      case 'double':
        return 'RealColumn';
      case 'bool':
        return 'BoolColumn';
      case 'DateTime':
        return 'DateTimeColumn';
      default:
        if (dartType.endsWith('Role') || dartType.endsWith('Enum')) {
          return 'IntColumn';
        }
        return 'TextColumn';
    }
  }

  String getTestValue(Map field) {
    final type = field['type'] as String;
    final name = field['name'] as String;

    switch (type) {
      case 'String':
        return "'test-$name'";
      case 'int':
        return '1';
      case 'double':
        return '70.5';
      case 'bool':
        return 'true';
      case 'DateTime':
        return 'DateTime(2025, 1, 15)';
      default:
        if (type.endsWith('Role')) {
          return '$type.${(field['enumValues'] as List?)?.first ?? 'athlete'}';
        }
        return "'test'";
    }
  }

  String convertDriftDefaultToDart(String driftDefault) {
    // Convert Drift default syntax to Dart default parameter syntax
    // e.g., "const Constant(false)" -> "false"
    // e.g., "const Constant(0)" -> "0"
    // e.g., "const Constant('value')" -> "'value'"
    final constantMatch =
        RegExp(r'const Constant\((.*)\)').firstMatch(driftDefault);
    if (constantMatch != null) {
      return constantMatch.group(1)!;
    }
    return driftDefault;
  }

  String pluralize(String word) {
    // Simple English pluralization
    if (word.endsWith('y') && !word.endsWith('ay') && !word.endsWith('ey')) {
      return '${word.substring(0, word.length - 1)}ies';
    } else if (word.endsWith('s') ||
        word.endsWith('sh') ||
        word.endsWith('ch') ||
        word.endsWith('x') ||
        word.endsWith('z')) {
      return '${word}es';
    } else {
      return '${word}s';
    }
  }
}

extension ListExtension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
