import 'package:flutter/material.dart';
import 'package:tree_man/src/module.dart';
import 'package:tree_man/src/provider_man.dart';

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
}

class _FlutterModuleState extends State<FlutterModule> {
  late final _module = widget.createModule();
  late final _asyncModule = Deps.waitAsyncModuleIsReady(_module);

  @override
  void initState() {
    super.initState();
    Deps.addModule(_module);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _asyncModule,
      builder: (context, _) {
        if (Deps.isModuleReady(_module)) {
          return widget.builder(context);
        }
        return widget.loading ??
            const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    Deps.removeModule(_module);
    super.dispose();
  }
}
