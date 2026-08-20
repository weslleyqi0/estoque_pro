import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart'; // for HapticFeedback
import 'package:go_router/go_router.dart';

class SaleScannerPage extends StatefulWidget {
  const SaleScannerPage({super.key});

  @override
  State<SaleScannerPage> createState() => _SaleScannerPageState();
}

class _SaleScannerPageState extends State<SaleScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasDetected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        _hasDetected = true;
        HapticFeedback.vibrate();
        context.pop(code.trim());
        break;
      }
    }
  }

  Future<void> _toggleTorch() => _controller.toggleTorch();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text('Escanear código de barras', style: context.textTheme.titleLarge?.copyWith(color: Colors.white)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final width = size.shortestSide * 0.93;
          final height = size.shortestSide * 0.45;
          final scanWindow = Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: width,
            height: height,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                scanWindow: scanWindow,
                tapToFocus: true,
                errorBuilder: _buildError,
                overlayBuilder: (context, _) {
                  return ScanWindowOverlay(
                    controller: _controller,
                    scanWindow: scanWindow,
                    borderColor: context.colorScheme.surface,
                    borderRadius: AppSpacing.borderRadius12,
                    borderWidth: 1,
                    color: Colors.black.withValues(alpha: 0.6),
                  );
                },
              ),

              Positioned(
                top: AppSpacing.appBarHeight + AppSpacing.space48,
                left: AppSpacing.space32,
                right: AppSpacing.space32,
                child: IgnorePointer(
                  child: Container(
                    padding: const .symmetric(
                      horizontal: AppSpacing.space16,
                      vertical: AppSpacing.space12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: AppSpacing.borderRadius16,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          AppIcons.barcodeScanner,
                          color: Colors.white,
                          size: AppSpacing.icon24,
                        ),
                        const SizedBox(width: AppSpacing.space8),
                        Flexible(
                          child: Text(
                            'Aponte a câmera para o código de barras do produto',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space24),
                    child: ValueListenableBuilder<MobileScannerState>(
                      valueListenable: _controller,
                      builder: (context, value, _) {
                        final torchUnavailable = value.torchState == TorchState.unavailable;
                        final torchOn = value.torchState == TorchState.on;

                        return _ScannerControlButton(
                          icon: torchOn ? AppIcons.flashOn : AppIcons.flashOff,
                          onPressed: torchUnavailable ? null : _toggleTorch,
                          tooltip: 'Lanterna',
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, MobileScannerException error) {
    final isPermissionDenied = error.errorCode == MobileScannerErrorCode.permissionDenied;

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AppIcons.barcodeScanner,
                color: Colors.white54,
                size: AppSpacing.icon56,
              ),
              const Gap(AppSpacing.space16),
              Text(
                isPermissionDenied
                    ? 'Permissão de câmera negada. Habilite o acesso nas configurações do aparelho para escanear códigos de barras.'
                    : 'Não foi possível acessar a câmera. Verifique se o dispositivo possui câmera disponível.',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const Gap(AppSpacing.space24),

              AppButton.outlined(
                onPressed: _controller.start,
                icon: AppIcons.play,
                label: 'Tentar novamente',
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _ScannerControlButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space12),
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: Colors.black.withValues(alpha: 0.6),
          shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: AppSpacing.space64,
              height: AppSpacing.space64,
              child: Icon(
                icon,
                color: enabled ? Colors.white : Colors.white30,
                size: AppSpacing.icon32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
