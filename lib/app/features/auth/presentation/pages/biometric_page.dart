import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class BiometricPage extends StatefulWidget {
  final BiometricViewModel viewModel;

  const BiometricPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  final ValueNotifier<bool> _isAvailable = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  @override
  void dispose() {
    _isAvailable.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    final available = await widget.viewModel.isAvailable();
    _isAvailable.value = available;

    if (!available) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.viewModel.setBiometricAuthenticated(true);
      });
    } else {
      widget.viewModel.authenticateCommand.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: .all(16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .stretch,
                children: [
                  Icon(
                    Symbols.fingerprint,
                    size: 100,
                    fontWeight: FontWeight.w600,
                  ),
                  Gap(24),
                  GestureDetector(
                    onTap: () => widget.viewModel.authenticateCommand.execute(),
                    child: Text(
                      'Use sua digital para\ndesbloquear o app',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            ListenableBuilder(
              listenable: widget.viewModel.authenticateCommand,
              builder: (context, _) {
                return GestureDetector(
                  onTap: () => widget.viewModel.authenticateCommand.execute(),
                  child: Text(
                    widget.viewModel.authenticateCommand.isRunning.toString(),
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
