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

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: AppIcons.fingerprint,
      iconColor: AppColors.primary,
      title: 'Autenticação Biométrica',
      subtitle: _isLoadingBiometric
          ? 'Verificando...'
          : _isBiometricAvailable
              ? 'Disponível neste dispositivo'
              : 'Indisponível no dispositivo',
      trailing: _isLoadingBiometric
          ? const SizedBox(
              width: AppSpacing.space16,
              height: AppSpacing.space16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : AppTag(
              title: _isBiometricAvailable ? 'Habilitada' : 'Não suportado',
              color: _isBiometricAvailable ? AppColors.success : AppColors.warning,
            ),
    );
  }
}
