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
  ClassE(ClassD d, ClassC c, ClassB b, ClassA a);
}

class AsyncModule extends Module {
  @override
  List<Inject<Object>> get injections => [
    Inject<ClassA>.asyncSingleton((i) async {
      return Future<ClassA>.delayed(
        const Duration(milliseconds: 300),
        ClassA.new,
      );
    }),
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
      Deps.addModule(mainModule);

      expect(Deps.get<ClassA>(), isA<ClassA>());
      expect(Deps.get<ClassB>(), isA<ClassB>());
      expect(Deps.get<ClassC>(), isA<ClassC>());
      expect(Deps.get<ClassD>(), isA<ClassD>());

      Deps.removeModule(mainModule);
    });

    test('disposeAll() when remove module', () {
      Deps.addModule(mainModule);

      expect(Deps.get<ClassA>(), isA<ClassA>());

      Deps.removeModule(mainModule);

      expect(() => Deps.get<ClassA>(), throwsA(isA<InjectException>()));
    });

    test('call dispose injection when remove module', () {
      Deps.addModule(mainModule);
      var disposeCalled = false;
      Deps.get<DisposeClass>().disposeMethod = () => disposeCalled = true;
      Deps.removeModule(mainModule);

      expect(disposeCalled, isTrue);
    });

    test('throws InjectException if dependency is not found', () {
      expect(() => Deps.get<ClassA>(), throwsA(isA<InjectException>()));
    });

    test('should override dependency', () {
      Deps
        ..addModule(mainModule)
        ..overrideInstance<ClassA>(MockClassA());
      expect(Deps.get<ClassA>().text, 'MockClassA');

      Deps.removeModule(mainModule);
      expect(() => Deps.get<ClassA>(), throwsA(isA<InjectException>()));
    });

    test('module is ready when there are no asynchronous dependencies', () {
      Deps.addModule(mainModule);
      expect(Deps.isModuleReady(mainModule), isTrue);
      Deps.removeModule(mainModule);
    });

    test('should wait for all asynchronous dependencies to be ready', () async {
      Deps.addModule(asyncModule);
      expect(() => Deps.get<ClassA>(), throwsA(isA<InjectException>()));

      await Deps.waitAsyncModuleIsReady(asyncModule);
      expect(Deps.get<ClassA>(), isA<ClassA>());

      Deps.removeModule(asyncModule);
    });

    test('module is not ready when there are asynchronous dependencies', () {
      Deps.addModule(asyncModule);
      expect(Deps.isModuleReady(asyncModule), isFalse);
      Deps
        ..removeModule(asyncModule)
        ..addModule(mainModule);
      expect(Deps.isModuleReady(mainModule), isTrue);
      Deps.removeModule(mainModule);
    });

    test('throws ModuleException if module already added', () {
      Deps.addModule(mainModule);
      expect(() => Deps.addModule(mainModule), throwsA(isA<ModuleException>()));
      Deps.removeModule(mainModule);
    });

    test('throws ModuleException if module is not found when remove', () {
      expect(
        () => Deps.removeModule(mainModule),
        throwsA(isA<ModuleException>()),
      );
    });
  });
}
