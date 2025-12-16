import 'package:flutter_test/flutter_test.dart';
import 'package:tree_man/tree_man.dart';

class MainClass {}

void main() {
  group('Inject', () {
    test('get() returns the same instance for singleton', () {
      final inject = Inject.singleton((_) => MainClass());
      final instance1 = inject.get(TreeMan);
      final instance2 = inject.get(TreeMan);
      expect(instance1, equals(instance2));
    });

    test('get() returns a new instance for factory', () {
      final inject = Inject.factory((_) => MainClass());
      final instance1 = inject.get(TreeMan);
      final instance2 = inject.get(TreeMan);
      expect(instance1, isNot(equals(instance2)));
    });

    test(
      'get() returns the same instance until disposed for lazy singleton',
      () {
        final inject = Inject.lazySingleton((_) => MainClass());
        final instance1 = inject.get(TreeMan);
        final instance2 = inject.get(TreeMan);
        expect(instance1, equals(instance2));
        inject.dispose();
        final instance3 = inject.get(TreeMan);
        expect(instance1, isNot(equals(instance3)));
      },
    );
  });
}
