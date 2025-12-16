import 'package:flutter/foundation.dart';
import 'package:tree_man/src/module.dart';

// ignore: one_member_abstracts
abstract interface class DependencyProvider {
  T get<T extends Object>();
}

abstract interface class Injector implements DependencyProvider {
  void removeModule(Module module);

  void addModule(Module module);

  Future<void> waitAsyncModuleIsReady(Module module);

  bool isModuleReady(Module module);

  @visibleForTesting
  void overrideInstance<T extends Object>(T instance);
}
