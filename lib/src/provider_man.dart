import 'dart:async';

import 'package:tree_man/src/exceptions.dart';
import 'package:tree_man/src/inject.dart';
import 'package:tree_man/src/injector.dart';
import 'package:tree_man/src/module.dart';

/// A class that manages a list of injections and
/// provides a way to retrieve them.
///
/// The injections are added to a [_TreeMan] via modules [_TreeMan.addModule],
/// which is then added to a list of instances.
/// The [_TreeMan.get] method retrieves the last added instance and returns the
/// injection of the specified type.
/// The [_TreeMan.removeModule] method disposes all injections
/// in the current instance.
extension IterableModifier<E> on Iterable<E> {
  E? lastWhereOrNull(bool Function(E) test) =>
      cast<E?>().lastWhere((v) => v != null && test(v), orElse: () => null);
}

typedef DependencyInjectorBuilder<T extends Object> = T Function(
  D Function<D extends Object>() getIt,
);

// ignore: non_constant_identifier_names
final Injector Deps = _TreeMan._();

class _TreeMan implements Injector {
  _TreeMan._();

  final Map<Module, Map<Type, Inject>> _modules = {};

  final Map<Module, Completer<List<Object?>>> _asyncModules = {};

  final Map<Type, Object> _overrideInstances = {};

  /// Adds a list of injections to the injection container.
  @override
  void addModule(Module module) {
    if (_modules.containsKey(module)) {
      throw ModuleException(message: 'Module $module is already added');
    }

    final injections = module.injections;
    final injects = <Type, Inject>{};
    final singletonInjects = <Inject>[];
    final asyncSingletonInjects = <Inject>[];
    for (var index = 0; index < injections.length; index++) {
      final inject = injections[index];
      if (inject.type == InjectType.singleton) {
        singletonInjects.add(inject);
      }
      if (inject.type == InjectType.asyncSingleton) {
        asyncSingletonInjects.add(inject);
      }
      injects.addAll({inject.objectType: inject});
    }
    _modules.addAll({module: injects});
    _initSingletons(singletonInjects);
    if (asyncSingletonInjects.isNotEmpty) {
      _asyncModules.addAll({module: Completer<List<Object?>>()});
      _initAsyncSingletons(module, asyncSingletonInjects);
    }
  }

  @override
  void removeModule(Module module) {
    final currentModule = _modules[module];
    if (currentModule == null) {
      throw ModuleException(message: 'Module $module not found');
    }

    for (final inject in currentModule.values) {
      inject.dispose();
    }
    _overrideInstances.clear();
    _asyncModules.remove(module);
    _modules.remove(module);
  }

  void _initSingletons(List<Inject> singletonInjects) {
    for (final inject in singletonInjects) {
      inject.get(this);
    }
  }

  Future<void> _initAsyncSingletons(
    Module module,
    List<Inject> asyncSingletonInjects,
  ) async {
    final asyncSingletons =
        asyncSingletonInjects.map((e) => e.getAsync(this)).toList();
    final result = await Future.wait<Object?>(asyncSingletons);
    _asyncModules[module]!.complete(result);
  }

  @override
  Future<void> waitAsyncModuleIsReady(Module module) =>
      _asyncModules[module]?.future ?? Future.value();

  @override
  bool isModuleReady(Module module) =>
      _asyncModules[module]?.isCompleted ?? true;

  /// Finds and returns an instance of type [T] from
  /// the list of registered instances.
  /// Throws an [InjectException] if no instance of type [T] is found.
  T _find<T extends Object>() {
    final instances = _modules.values.toList();
    T? currentInstance;
    for (var index = instances.length - 1; index >= 0; index--) {
      final instance = instances[index];
      currentInstance = _getByInjectorInstances<T>(instance);
      if (currentInstance != null) {
        break;
      }
    }

    if (currentInstance == null) {
      throw InjectException(
        message: "$T dont'exist or is not ready because "
            'is asynchronous',
      );
    }

    return currentInstance;
  }

  /// Used for get instance
  B? _getByInjectorInstances<B extends Object>(Map<Type, Inject> instances) {
    final instance = instances[B];
    if (instance != null) {
      return instance.get(this) as B?;
    }
    return null;
  }

  @override
  void overrideInstance<T extends Object>(T instance) {
    if (_overrideInstances.containsKey(T)) {
      throw ArgumentError('$T already was override');
    }
    _overrideInstances[T] = instance;
  }

  /// Retrieves the injection of the specified
  /// type from the last added instance.
  @override
  T get<T extends Object>() {
    final overrideInstance = _getOverrideInstance<T>();
    if (overrideInstance != null) return overrideInstance;
    return _find<T>();
  }

  T? _getOverrideInstance<T extends Object>() {
    if (_overrideInstances.containsKey(T)) {
      return _overrideInstances[T]! as T;
    }
    return null;
  }
}
