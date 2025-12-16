import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tree_man/tree_man.dart';

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

class AsyncMainModule extends Module {
  @override
  List<Inject<Object>> get injections => [
        Inject<MainClass>.asyncSingleton(
          (i) async {
            return Future<MainClass>.delayed(
              const Duration(milliseconds: 300),
              MainClass.new,
            );
          },
        ),
      ];
}

void main() {
  group('FlutterModule', () {
    testWidgets('injected object is available in child widget tree',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterModule(
            createModule: MainModule.new,
            builder: (_) => const Text('Teste'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(Deps.get<MainClass>(), isA<MainClass>());
    });

    testWidgets(
        'injected async object is available in child '
        'widget tree and show default loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterModule(
            createModule: AsyncMainModule.new,
            builder: (_) => const Text('Teste'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(Deps.get<MainClass>(), isA<MainClass>());
    });

    testWidgets(
        'injected async object is available in child '
        'widget tree and show custom loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterModule(
            createModule: AsyncMainModule.new,
            builder: (_) => const Text('Teste'),
            loading: const Text('loading'),
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('loading'), findsNothing);
      expect(Deps.get<MainClass>(), isA<MainClass>());
    });
  });
}
