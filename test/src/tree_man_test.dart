// ignore_for_file: avoid_unused_constructor_parameters

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree_man/src/exceptions.dart';
import 'package:tree_man/tree_man.dart';

class DisposeClass {
  VoidCallback? disposeMethod;

  void dispose() {
    disposeMethod?.call();
  }
}

class ClassA {
  String get text => 'ClassA';
}

class MockClassA extends ClassA {
  @override
  String get text => 'MockClassA';
}

class ClassB {
  ClassB(ClassA a);
}

class ClassC {
  ClassC(ClassB b);
}

class ClassD {
  ClassD(ClassC c);
}

class ClassE {
  ClassE(
    ClassD d,
    ClassC c,
    ClassB b,
    ClassA a,
  );
}

class ClassF {
  ClassF(ClassA a, ClassB b);
}

class AsyncModule extends Module {
  @override
  List<Inject<Object>> get injections => [
        Inject<ClassA>.asyncSingleton(
          (i) async {
            return Future<ClassA>.delayed(
              const Duration(milliseconds: 300),
              ClassA.new,
            );
          },
        ),
        Inject<ClassB>.asyncSingleton(
          (i) async {
            return Future<ClassB>.delayed(
              const Duration(milliseconds: 200),
              () => ClassB(i.get<ClassA>()),
            );
          },
        ),
        Inject<ClassF>.asyncSingleton(
          (i) async {
            return Future<ClassF>.delayed(
              const Duration(milliseconds: 100),
              () => ClassF(i.get<ClassA>(), i.get<ClassB>()),
            );
          },
        ),
        Inject<ClassC>.singleton((i) => ClassC(i.get<ClassB>())),
      ];
}

class MainModule extends Module {
  @override
  List<Inject<Object>> get injections => [
        Inject<DisposeClass>.singleton(
          (_) => DisposeClass(),
          dispose: (instance) => instance.dispose(),
        ),
        Inject<ClassA>.factory((_) => ClassA()),
        Inject<ClassB>.factory((i) => ClassB(i.get<ClassA>())),
        Inject<ClassC>.factory((i) => ClassC(i.get<ClassB>())),
        Inject<ClassD>.factory((i) => ClassD(i.get<ClassC>())),
        Inject<ClassE>.factory(
          (i) => ClassE(
            i.get<ClassD>(),
            i.get<ClassC>(),
            i.get<ClassB>(),
            i.get<ClassA>(),
          ),
        ),
      ];
}

void main() {
  final mainModule = MainModule();
  final asyncModule = AsyncModule();

  group('TreeMan', () {
    test('get() returns correct dependency', () {
      TreeMan.addModule(mainModule);

      expect(TreeMan.get<ClassA>(), isA<ClassA>());
      expect(TreeMan.get<ClassB>(), isA<ClassB>());
      expect(TreeMan.get<ClassC>(), isA<ClassC>());
      expect(TreeMan.get<ClassD>(), isA<ClassD>());

      TreeMan.removeModule(mainModule);
    });

    test('disposeAll() when remove module', () {
      TreeMan.addModule(mainModule);

      expect(TreeMan.get<ClassA>(), isA<ClassA>());

      TreeMan.removeModule(mainModule);

      expect(
        () => TreeMan.get<ClassA>(),
        throwsA(isA<UnregisteredInstanceException>()),
      );
    });

    test('call dispose injection when remove module', () {
      TreeMan.addModule(mainModule);
      var disposeCalled = false;
      TreeMan.get<DisposeClass>().disposeMethod = () => disposeCalled = true;
      TreeMan.removeModule(mainModule);

      expect(disposeCalled, isTrue);
    });

    test('throws InjectException if dependency is not found', () {
      expect(
        () => TreeMan.get<ClassA>(),
        throwsA(isA<UnregisteredInstanceException>()),
      );
    });

    test('should override dependency', () {
      TreeMan
        ..addModule(mainModule)
        ..overrideInstance<ClassA>(MockClassA());
      expect(TreeMan.get<ClassA>().text, 'MockClassA');

      TreeMan.removeModule(mainModule);
      expect(
        () => TreeMan.get<ClassA>(),
        throwsA(isA<UnregisteredInstanceException>()),
      );
    });

    test('module is ready when there are no asynchronous dependencies', () {
      TreeMan.addModule(mainModule);
      expect(TreeMan.isModuleReady(mainModule), isTrue);
      TreeMan.removeModule(mainModule);
    });

    test('should wait for all singleton asynchronous dependencies to be ready',
        () async {
      TreeMan.addModule(asyncModule);
      await TreeMan.waitAsyncModuleIsReady(asyncModule);

      expect(TreeMan.get<ClassA>(), isA<ClassA>());
      expect(TreeMan.get<ClassB>(), isA<ClassB>());
      expect(TreeMan.get<ClassF>(), isA<ClassF>());
      expect(TreeMan.get<ClassC>(), isA<ClassC>());

      TreeMan.removeModule(asyncModule);
    });

    test(
        'module is not ready when there are singleton '
        'asynchronous dependencies', () {
      TreeMan.addModule(asyncModule);
      expect(TreeMan.isModuleReady(asyncModule), isFalse);
      TreeMan
        ..removeModule(asyncModule)
        ..addModule(mainModule);
      expect(TreeMan.isModuleReady(mainModule), isTrue);
      TreeMan.removeModule(mainModule);
    });

    test(
        'throw a UninitializedInstanceException when an asynchronous '
        'dependency has not yet been initialized.', () async {
      TreeMan.addModule(asyncModule);
      expect(
        () => TreeMan.get<ClassA>(),
        throwsA(isA<UninitializedInstanceException>()),
      );
      expect(
        () => TreeMan.get<ClassC>(),
        throwsA(isA<UninitializedInstanceException>()),
      );
    });

    test('throws ModuleException if module already added', () {
      TreeMan.addModule(mainModule);
      expect(
        () => TreeMan.addModule(mainModule),
        throwsA(isA<ModuleException>()),
      );
      TreeMan.removeModule(mainModule);
    });

    test('throws ModuleException if module is not found when remove', () {
      expect(
        () => TreeMan.removeModule(mainModule),
        throwsA(isA<ModuleException>()),
      );
    });
  });
}
