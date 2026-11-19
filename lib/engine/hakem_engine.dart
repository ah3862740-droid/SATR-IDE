class HakemEngine {
  final Map<String, dynamic> variables = {};
  final List<String> output = [];

  int _steps = 0;

  String run(String source) {
    variables.clear();
    output.clear();
    _steps = 0;

    try {
      _executeLines(source.split('\n'));
      return output.isEmpty
          ? 'تم التنفيذ بدون مخرجات.'
          : output.join('\n');
    } catch (e) {
      return 'خطأ: $e';
    }
  }

  void _executeLines(List<String> lines, {int depth = 0}) {
    if (depth > 10) {
      throw FormatException('التكرار المتداخل عميق جدًا.');
    }

    for (int i = 0; i < lines.length; i++) {
      final raw = lines[i];
      final line = raw.trim();

      if (line.isEmpty || line.startsWith('#')) continue;

      final repeatMatch =
          RegExp(r'^كرر\s+(\d+)\s*:$').firstMatch(line);

      if (repeatMatch != null) {
        final count = int.parse(repeatMatch.group(1)!);

        if (count > 1000) {
          throw FormatException('الحد الأقصى للتكرار هو 1000.');
        }

        final parentIndent = raw.length - raw.trimLeft().length;
        final body = <String>[];

        int j = i + 1;

        while (j < lines.length) {
          final next = lines[j];
          final nextTrimmed = next.trim();

          if (nextTrimmed.isEmpty || nextTrimmed.startsWith('#')) {
            body.add(next);
            j++;
            continue;
          }

          final indent = next.length - next.trimLeft().length;

          if (indent <= parentIndent) break;

          body.add(next);
          j++;
        }

        if (body.isEmpty) {
          throw FormatException('أمر كرر يحتاج أوامر بداخله.');
        }

        for (int n = 0; n < count; n++) {
          _executeLines(body, depth: depth + 1);
        }

        i = j - 1;
        continue;
      }

      _steps++;
      if (_steps > 10000) {
        throw FormatException('تم تجاوز حد أوامر التنفيذ.');
      }

      final printMatch =
          RegExp(r'^اطبع\((.*)\)$').firstMatch(line);

      if (printMatch != null) {
        output.add(_value(printMatch.group(1)!));
        continue;
      }

      final variableMatch = RegExp(
        r'^خلي\s+([\w\u0600-\u06FF]+)\s*=\s*(.+)$',
      ).firstMatch(line);

      if (variableMatch != null) {
        variables[variableMatch.group(1)!] =
            _parseValue(variableMatch.group(2)!);
        continue;
      }

      throw FormatException(
        'تعليمة غير مدعومة في السطر ${i + 1}: $line',
      );
    }
  }

  dynamic _parseValue(String source) {
    final value = source.trim();

    if (variables.containsKey(value)) {
      return variables[value];
    }

    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }

    final number = num.tryParse(value);
    if (number != null) return number;

    if (value == 'صح') return true;
    if (value == 'غلط') return false;

    return value;
  }

  String _value(String source) {
    return _parseValue(source).toString();
  }
}
