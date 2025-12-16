import 'package:flutter/material.dart';
import 'package:tree_man/tree_man.dart';

class MainClass {
  final String name = 'Dependency';
}

class MainModule extends Module {
  @override
  List<Inject<Object>> get injections => [
        Inject<MainClass>.singleton(
          (_) => MainClass(),
        ),
      ];
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const FirstPage(),
        '/second': (context) => const SecondPage(),
      },
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FlutterModule(
        createModule: MainModule.new,
        builder: (_) => Center(
          child: Text('First Page - ${Deps.get<MainClass>().name}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/second'),
        child: const Icon(Icons.arrow_downward),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Second Page - ${Deps.get<MainClass>().name}'),
      ),
    );
  }
}
