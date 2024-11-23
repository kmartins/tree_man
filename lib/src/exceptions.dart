/// A custom exception class for injection errors.
///
/// This class implements the built-in [Exception] class and
/// adds a custom [message] property.
/// The [toString] method is overridden to return a
/// formatted string with the exception message.
class InjectException implements Exception {
  const InjectException({
    required this.message,
  });
  final String message;

  @override
  String toString() => 'InjectException: $message';
}

class ModuleException implements Exception {
  const ModuleException({
    required this.message,
  });
  final String message;

  @override
  String toString() => 'ModuleException: $message';
}
