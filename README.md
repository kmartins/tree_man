# Tree man

This package helps you to manage any dependencies in your project without need to use context and makes possible to create dependencies for modules. The objective is help any developer to manage dependencies with a easy to use API.

It's basically the copy of this package [Flutter Injections](https://github.com/gabuldev/flutter_injections).

## Why Tree Man?

- __Fast and Efficient__
  > Flutter Injections use search-tree to get the dependencies, this improve the speed to get them, and use less CPU to search for specific objects.
- __Module Injections__
  > Create module injections that have all dependencies needed on your widgets. I.E __`HomeModule`__ have all dependencies needed on __`HomePage`__.
- __Easy to use__
  > The focus is to keep it simple to handle dependencies on large scale applications.
- __Auto dispose__
  > Objects are auto disposed when the `module` is removed from the Widget Tree.

## How to use

It`s simple, just three steps:

1. Add the TreeMan to __pubspec.yaml__ file
    ```yaml
    tree_man: ^any # or current version
    ```
2. Create a __Module__
   ```dart
    class MainClass {
        final String name = 'name';
    }

    class MainModule extends Module {
        @override
        List<Inject<Object>> get injections => [
            Inject<MainClass>.singleton(
            (_) => MainClass(),
            ),
        ];
    }
   ```
3. Create your __DepsModule__ and pass the `module`(Sync Module) 
    ```dart
    MaterialApp(
        home: FlutterModule(
            createModule: MainModule.new,
            builder: (_) => const Text('Teste'),
        ),
    ),
    ``` 

4. And finally, use it to get the dependencies:
```dart
final controller = TreeMan.get<YourController>();
```

### Async Injections

You can use the __`Inject.asyncSingleton`__ to create async injections.

For know if the module is ready you can use the __`Deps.isModuleReady`__ method and for waiting the async module to be ready you can use the __`Deps.waitAsyncModuleIsReady`__ method.

The `FlutterModule` widget is already in control of this for default and has a __`loading`__ parameter that is used when the module is not ready, if null then the `CircularProgressIndicator` is used.

```dart
MaterialApp(
    home: FlutterModule(
        createModule: AsyncMainModule.new,
        builder: (_) => const Text('Teste'),
        loading: const Text('loading'),
    ),
),
````

> If all injections are sync, the loading will not appear.

## Dispose

When you use the `FlutterModule` widget, the dependencies of the module are disposed of when the widget is removed from the tree and the **dispose** method of `Injection` is called.

```dart
 Inject<DisposeClass>.singleton(
    (_) => DisposeClass(),
    dispose: (instance) => instance.dispose(),
),
```

## Module

Called the `Deps.addModule` for added a module e for remove you must call `Deps.removeModule` that will dispose all injections in the module automatically.

The `FlutterModule` widget calls these methods by default.

## Test

You can override the dependencies using the __`overrideInstance`__ method.

```dart
Deps.overrideInstance<YourRepository>(YourRepositoryMock());
```

then

```dart
TreeMan.get<YourRepository>() will return `YourRepositoryMock`.
```

## 📝 Maintainers

[Kauê Martins](https://github.com/kmartins)

## 🤝 Support

You liked this package? Then give it a ⭐️. If you want to help then:

- Fork this repository
- Send a Pull Request with new features
- Share this package
- Create issues if you find a bug or want to suggest a new extension

**Pull Request title follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). </br>**

## 📝 License

Copyright © 2024 [Kauê Martins](https://github.com/kmartins).<br />
This project is [MIT](https://opensource.org/licenses/MIT) licensed.