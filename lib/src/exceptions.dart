import 'package:tree_man/tree_man.dart';

/// Exception for Unregistered instance.
///
/// [message] : message of exception<br>
/// [objectType] : unregistered object type<br>
class UnregisteredInstanceException implements Exception {
  const UnregisteredInstanceException({
    required this.message,
    required this.objectType,
  });

  final String message;
  final Type objectType;

  @override
  String toString() => 'UnregisteredInstanceException: $message';
}

class ModuleException implements Exception {
  const ModuleException({required this.message});

  final String message;

  @override
  String toString() => 'ModuleException: $message';
}

/// Exception for Uninitialized Instance.
///
/// [message] : message of exception<br>
/// [inject] : instance injection<br>
class UninitializedInstanceException implements Exception {
  const UninitializedInstanceException({
    required this.message,
    required this.inject,
  });

  final String message;
  final Inject inject;

  @override
  String toString() => 'UninitializedInstanceException: $message';
}
