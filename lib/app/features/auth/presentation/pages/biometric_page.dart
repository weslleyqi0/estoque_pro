import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BiometricPage extends StatefulWidget {
  final BiometricViewModel Function() viewModelFactory;

  const BiometricPage({
    super.key,
    required this.viewModelFactory,
  });

  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  late final BiometricViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModelFactory();
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
                    AppIcons.fingerprint,
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
              icon: AppIcons.fingerprint,
              isFullWidth: true,
            ),
            Gap(AppSpacing.space8),
            AppButton.text(
              onPressed: () => viewModel.usePassword(),
              label: 'USAR SENHA',
              icon: AppIcons.keyboard,
              isFullWidth: true,
            ),
            Gap(AppSpacing.space24),
          ],
        ),
      ),
    );
  }
}
