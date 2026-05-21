import 'failures.dart';

class ErrorHandler {
  const ErrorHandler();

  Failure toFailure(Object error) => UnknownFailure(error.toString());
}
