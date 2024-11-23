import 'package:flutter_test/flutter_test.dart';
import 'package:tree_man/src/exceptions.dart';

void main() {
  group('InjectException', () {
    test('toString returns correct message', () {
      const exception = InjectException(message: 'Test message');
      expect(exception.toString(), 'InjectException: Test message');
    });
  });

  group('ModuleException', () {
    test('toString returns correct message', () {
      const exception = ModuleException(message: 'Test message');
      expect(exception.toString(), 'Module: Test message');
    });
  });
}
