import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/api/json_read.dart';

void main() {
  group('readString / readText', () {
    test('trims and drops blanks', () {
      expect(readString('  a '), 'a');
      expect(readString('   '), isNull);
      expect(readString(null), isNull);
      expect(readString(12), '12');
      expect(readString({'a': 1}), isNull);
    });
    test('readText drops placeholders like N/A', () {
      expect(readText('N/A'), isNull);
      expect(readText('null'), isNull);
      expect(readText('Courchevel'), 'Courchevel');
    });
  });

  group('numbers', () {
    test('accepts numbers and numeric strings', () {
      expect(readNum(3), 3);
      expect(readNum('4.5'), 4.5);
      expect(readNum(' 7 '), 7);
      expect(readNum('abc'), isNull);
      expect(readNum(double.nan), isNull);
      expect(readNum(double.infinity), isNull);
      expect(readInt(2.6), 3);
      expect(readInt('9'), 9);
      expect(readDouble(1), 1.0);
    });
  });

  test('readBool understands strings and numbers', () {
    expect(readBool(true), isTrue);
    expect(readBool('false'), isFalse);
    expect(readBool('TRUE'), isTrue);
    expect(readBool(0), isFalse);
    expect(readBool('maybe'), isNull);
  });

  test('readDate parses ISO and converts to local', () {
    final d = readDate('2026-11-19T03:00:00.000Z')!;
    expect(d.isUtc, isFalse);
    expect(d.toUtc(), DateTime.utc(2026, 11, 19, 3));
    expect(readDate('not a date'), isNull);
    expect(readDate(''), isNull);
  });

  test('readList skips non-maps and elements that throw', () {
    final out = readList<int>([
      {'v': 1},
      'junk',
      null,
      {'v': 'x'},
      {'v': 3},
    ], (j) => j['v'] as int);
    expect(out, [1, 3]);
    expect(readList<int>('nope', (j) => 1), isEmpty);
  });

  test('readId falls back to _id', () {
    expect(readId({'id': 'a'}), 'a');
    expect(readId({'_id': 'b'}), 'b');
    expect(readId({}), '');
  });
}
