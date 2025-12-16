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
final Injector TreeMan = _TreeMan._();

class _TreeMan implements Injector {
  _TreeMan._();

  final Map<Module, Map<Type, Inject>> _modules = {};

  final Map<Module, Completer<void>> _asyncModules = {};

  final Map<Type, Object> _overrideInstances = {};

  final Set<Type> _allInjections = {};

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
      _allInjections.add(inject.objectType);
    }
    if (asyncSingletonInjects.isNotEmpty) {
      final moduleCompleter = Completer<void>();
      _asyncModules.addAll({module: moduleCompleter});
      _initAsyncSingletons(moduleCompleter, asyncSingletonInjects);
    }

    _modules.addAll({module: injects});
    _initSingletons(module, singletonInjects);
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

  Future<void> _initSingletons(
    Module module,
    List<Inject> singletonInjects,
  ) async {
    if (!isModuleReady(module)) {
      await waitAsyncModuleIsReady(module);
    }
    for (final inject in singletonInjects) {
      inject.get(this);
    }
  }

  Future<void> _initAsyncSingletons(
    Completer<void> moduleCompleter,
    List<Inject> asyncSingletonInjects,
  ) async {
    final asyncSingletons =
        asyncSingletonInjects.map((e) => e.getAsync(this)).toList();
    await Future.wait(asyncSingletons);
    moduleCompleter.complete();
  }

  @override
  Future<void> waitAsyncModuleIsReady(Module module) =>
      _asyncModules[module]?.future ?? Future.value();

  @override
  bool isModuleReady(Module module) =>
      _asyncModules[module]?.isCompleted ?? true;

  /// Finds and returns an instance of type [T] from
  /// the list of registered instances.
  /// Throws an [UnregisteredInstanceException] if no instance
  /// of type [T] is found.
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
      throw UnregisteredInstanceException(
        message: 'No registered dependency found for $T. Please ensure '
            'the dependency is registered',
        objectType: T,
      );
    }

    return currentInstance;
  }

  /// Used for get instance
  B? _getByInjectorInstances<B extends Object>(Map<Type, Inject> instances) {
    final instance = instances[B];
    if (instance != null) {
      final object = instance.get(this) as B?;
      if (object == null) {
        throw UninitializedInstanceException(
          message: "The instance for '$B' has not been initialized. Call "
              '`TreeMan.waitAsyncModuleIsReady(module)` before '
              'attempting to retrieve it.',
          inject: instance,
        );
      }

      return object;
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
    if (overrideInstance != null) {
      return overrideInstance;
    }

    return _find<T>();
  }

  T? _getOverrideInstance<T extends Object>() {
    if (_overrideInstances.containsKey(T)) {
      return _overrideInstances[T]! as T;
    }
    return null;
  }
}
