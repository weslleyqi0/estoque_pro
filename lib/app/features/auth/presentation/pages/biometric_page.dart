import 'package:design_system/design_system.dart';
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
  BiometricViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.checkAvailability();
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  Gap(AppSpacing.space24),
                  Text(
                    'Use sua digital para\ndesbloquear o app',
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            AppButton(
              onPressed: () => viewModel.authenticateCommand.execute(),
              label: 'Usar digital',
              icon: Symbols.fingerprint,
              isFullWidth: true,
            ),
            Gap(AppSpacing.space8),
            AppButton.text(
              onPressed: () => viewModel.usePassword(),
              label: 'USAR SENHA',
              icon: Symbols.keyboard,
              isFullWidth: true,
            ),
            Gap(AppSpacing.space24),
          ],
        ),
      ),
    );
  }
}
