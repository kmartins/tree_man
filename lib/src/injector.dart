import 'package:flutter/foundation.dart';
import 'package:tree_man/src/module.dart';

abstract interface class Injector {
  T get<T extends Object>();

  void removeModule(Module module);

  void addModule(Module module);

  Future<void> waitAsyncModuleIsReady(Module module);

  bool isModuleReady(Module module);

  @visibleForTesting
  void overrideInstance<T extends Object>(T instance);
}
