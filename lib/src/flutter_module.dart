import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tree_man/tree_man.dart';

typedef ModuleBuilder = Module Function();

/// A widget that provides dependency injection to its child widget tree.
class FlutterModule extends StatefulWidget {
  const FlutterModule({
    required this.createModule,
    required this.builder,
    this.loading,
    super.key,
  });

  final WidgetBuilder builder;
  final ModuleBuilder createModule;
  final Widget? loading;

  @override
  State<FlutterModule> createState() => _FlutterModuleState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<ModuleBuilder>('createModule', createModule))
      ..add(DiagnosticsProperty<WidgetBuilder>('builder', builder))
      ..add(DiagnosticsProperty<Widget>('loading', loading));
    super.debugFillProperties(properties);
  }
}

class _FlutterModuleState extends State<FlutterModule> {
  late final _module = widget.createModule();
  late final _asyncModule = TreeMan.waitAsyncModuleIsReady(_module);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(
        DiagnosticsProperty<bool>(
          'isModuleReady',
          TreeMan.isModuleReady(_module),
        ),
      )
      ..add(
        DiagnosticsProperty<List<Inject<Object>?>>(
          'injections',
          _module.injections,
        ),
      );
    super.debugFillProperties(properties);
  }

  @override
  void initState() {
    super.initState();
    TreeMan.addModule(_module);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _asyncModule,
      builder: (context, _) {
        if (TreeMan.isModuleReady(_module)) {
          return widget.builder(context);
        }
        return widget.loading ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    TreeMan.removeModule(_module);
    super.dispose();
  }
}
