import 'package:flutter/foundation.dart';
import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _running = false;
  bool get running => _running;

  Result<T>? _result;
  Result<T>? get result => _result;

  bool get error => _result is Error<T>;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(Future<Result<T>> Function() action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

class Command0<T> extends Command<T> {
  Command0(this.action);
  final CommandAction0<T> action;

  Future<void> execute() async {
    await _execute(() => action());
  }
}

class Command1<T, A> extends Command<T> {
  Command1(this.action);
  final CommandAction1<T, A> action;

  Future<void> execute(A argument) async {
    await _execute(() => action(argument));
  }
}
