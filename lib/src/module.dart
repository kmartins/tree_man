import 'package:tree_man/src/inject.dart';

abstract class Module {
  List<Inject<Object>> get injections;
}
