import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

class TestViewModel extends BaseViewModel {
  TestViewModel({super.tag});

  void performAction() {
    logInfo('Action performed');
    notifyListeners();
  }

  void performError() {
    logError('Error occurred', Exception('Boom'));
  }
}

void main() {
  late TestViewModel viewModel;

  setUp(() {
    viewModel = TestViewModel();
  });

  test('isDisposed is initially false', () {
    expect(viewModel.isDisposed, isFalse);
  });

  test('notifyListeners notifies when not disposed', () {
    var notified = false;
    viewModel.addListener(() => notified = true);

    viewModel.performAction();

    expect(notified, isTrue);
  });

  test('dispose sets isDisposed to true and prevents notification errors', () {
    viewModel.dispose();

    expect(viewModel.isDisposed, isTrue);

    // Calling notifyListeners after dispose should safely do nothing without throwing
    expect(() => viewModel.notifyListeners(), returnsNormally);
  });

  test('logging methods execute without errors', () {
    expect(() => viewModel.logInfo('Info message'), returnsNormally);
    expect(() => viewModel.logDebug('Debug message'), returnsNormally);
    expect(() => viewModel.logWarning('Warning message'), returnsNormally);
    expect(() => viewModel.logError('Error message'), returnsNormally);
  });
}
