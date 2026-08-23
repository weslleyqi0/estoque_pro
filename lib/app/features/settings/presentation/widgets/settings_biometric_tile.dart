import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/biometric_viewmodel.dart';
import 'package:estoque_pro/app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:flutter/material.dart';

class SettingsBiometricTile extends StatefulWidget {
  final BiometricViewModel biometricViewModel;

  const SettingsBiometricTile({
    super.key,
    required this.biometricViewModel,
  });

  @override
  State<SettingsBiometricTile> createState() => _SettingsBiometricTileState();
}

class _SettingsBiometricTileState extends State<SettingsBiometricTile> {
  bool _isBiometricAvailable = false;
  bool _isLoadingBiometric = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final available = await widget.biometricViewModel.isAvailable();
      if (mounted) {
        setState(() {
          _isBiometricAvailable = available;
          _isLoadingBiometric = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _isLoadingBiometric = false;
        });
      }
    }
  }

  Future<void> _onToggleBiometrics(bool enable) async {
    await widget.biometricViewModel.authenticateCommand.execute();
    final authenticated = widget.biometricViewModel.authenticateCommand.isSuccess &&
        widget.biometricViewModel.authenticateCommand.value == true;
    if (!authenticated) {
      if (mounted) {
        AppSnackbar.warning(context, 'Não foi possível confirmar a biometria.');
      }
      return;
    }

    if (enable) {
      await widget.biometricViewModel.setBiometricEnabled(true);
      if (mounted) {
        AppSnackbar.success(context, 'Autenticação biométrica ativada com sucesso!');
      }
    } else {
      await widget.biometricViewModel.setBiometricEnabled(false);
      if (mounted) {
        AppSnackbar.info(context, 'Autenticação biométrica desativada.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.biometricViewModel,
      builder: (context, _) {
        final isEnabled = widget.biometricViewModel.isBiometricEnabled;

        if (_isLoadingBiometric) {
          return const SettingsTile(
            icon: AppIcons.fingerprint,
            iconColor: AppColors.primary,
            title: 'Autenticação Biométrica',
            subtitle: 'Verificando compatibilidade...',
            trailing: SizedBox(
              width: AppSpacing.space16,
              height: AppSpacing.space16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!_isBiometricAvailable) {
          return const SettingsTile(
            icon: AppIcons.fingerprint,
            iconColor: AppColors.primary,
            title: 'Autenticação Biométrica',
            subtitle: 'Não disponível neste dispositivo',
            trailing: AppTag(
              title: 'Não suportado',
              color: AppColors.warning,
            ),
          );
        }

        return SettingsTile(
          icon: AppIcons.fingerprint,
          iconColor: isEnabled ? AppColors.primary : context.colorScheme.onSurface.withValues(alpha: 0.4),
          title: 'Autenticação Biométrica',
          subtitle: isEnabled
              ? 'Exigir digital ao abrir o app'
              : 'Desabilitada (acesso direto após login)',
          trailing: Switch(
            value: isEnabled,
            onChanged: _onToggleBiometrics,
          ),
        );
      },
    );
  }
}
