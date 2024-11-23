import 'package:tree_man/src/injector.dart';

enum InjectType { factory, singleton, lazySingleton, asyncSingleton }

/// A class that represents an injection of a dependency.
///
/// An injection can be of four types: factory, singleton, lazySingleton,
/// and asyncSingleton.
/// The type of injection is determined by the [InjectType]
/// parameter passed to the constructor.
///
/// The [Inject] class has three factory constructors:
/// [Inject.factory], [Inject.singleton], [Inject.lazySingleton], and
/// [Inject.asyncSingleton].
/// Each constructor creates an instance of [Inject]
/// with the corresponding [InjectType].
///
/// The [Inject.get] method returns the value of the injected dependency.
/// If the injection is of type factory, the value is always recomputed.
/// If the injection is of type singleton, lazySingleton or asyncSingleton
/// the value is computed only once and cached for future use.
///
/// The injected dependency is computed by calling the [Bind]
/// function passed to the constructor.
/// The [Bind] function takes a [Injector] instance as a parameter and
/// returns an instance of type [T].
///
/// Example usage:
///
/// ```dart
/// final myInject = Inject.singleton((i) => MyDependency());
/// final myDependency = myInject.get(myFlutterInjections);
/// ```
///
typedef AsyncBind<T extends Object> = Future<T> Function(Injector I);

typedef Bind<T extends Object> = T Function(Injector i);

typedef Dispose<T extends Object> = void Function(T instance);

class Inject<T extends Object> {
  Inject._syncCall(this._syncCall, this.type, this._dispose)
      : objectType = T,
        _asyncCall = null;

  Inject._asyncCall(this._asyncCall, this.type, this._dispose)
      : objectType = T,
        _syncCall = null;

  factory Inject.lazySingleton(
    Bind<T> call, {
    Dispose<T>? dispose,
  }) =>
      Inject._syncCall(call, InjectType.lazySingleton, dispose);

  factory Inject.singleton(
    Bind<T> call, {
    Dispose<T>? dispose,
  }) =>
      Inject._syncCall(call, InjectType.singleton, dispose);

  factory Inject.factory(
    Bind<T> call, {
    Dispose<T>? dispose,
  }) =>
      Inject._syncCall(call, InjectType.factory, dispose);

  factory Inject.asyncSingleton(
    AsyncBind<T> call, {
    Dispose<T>? dispose,
  }) =>
      Inject._asyncCall(call, InjectType.asyncSingleton, dispose);

  final Bind<T>? _syncCall;
  final AsyncBind<T>? _asyncCall;
  final InjectType type;
  final Type objectType;
  final Dispose<T>? _dispose;
  T? instance;

  Future<T?> getAsync(Injector i) async =>
      instance ??= await _asyncCall?.call(i);

  T? get(Injector i) {
    if (type == InjectType.factory) {
      instance = null;
    }
    return instance ??= _syncCall?.call(i);
  }

  void dispose() {
    if (instance != null) {
      _dispose?.call(instance!);
    }
    instance = null;
  }
}
