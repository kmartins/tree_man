import 'package:flutter_test/flutter_test.dart';
import 'package:tree_man/src/exceptions.dart';
import 'package:tree_man/tree_man.dart';

void main() {
  group('UnregisteredInstanceException', () {
    test('toString returns correct message', () {
      const exception = UnregisteredInstanceException(
        message: 'Test message',
        objectType: String,
      );
      expect(
        exception.toString(),
        'UnregisteredInstanceException: Test message',
      );
      expect(exception.objectType, String);
    });
  });

  group('UninitializedInstanceException', () {
    test('toString returns correct message', () {
      final exception = UninitializedInstanceException(
        message: 'Test message',
        inject: Inject<String>.factory((_) => ''),
      );
      expect(
        exception.toString(),
        'UninitializedInstanceException: Test message',
      );
      expect(exception.inject.objectType, String);
    });
  });

  group('ModuleException', () {
    test('toString returns correct message', () {
      const exception = ModuleException(message: 'Test message');
      expect(exception.toString(), 'ModuleException: Test message');
    });
  });
}
