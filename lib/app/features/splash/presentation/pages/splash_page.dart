import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  final AuthViewModel authViewModel;

  const SplashPage({
    super.key,
    required this.authViewModel,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  double _progress = 0.0;
  String _statusText = 'Iniciando aplicativo...';

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Etapa inicial de carregamento visual
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _progress = 0.35;
      _statusText = 'Verificando conexão e dados...';
    });

    // 2. Aguarda estabilização do Auth e Perfil do Usuário
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _progress = 0.75;
      _statusText = 'Preparando seu painel...';
    });

    // 3. Conclusão da barra de progresso
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _progress = 1.0;
      _statusText = 'Pronto!';
    });

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    _navigateNext();
  }

  void _navigateNext() {
    final auth = widget.authViewModel;
    final isAuthenticated = auth.isAuthenticated;
    final isBiometricAuth = auth.isBiometricAuthenticated;
    final currentUser = auth.currentUser;

    if (!isAuthenticated) {
      context.go(AppRoutes.login);
      return;
    }

    if (currentUser != null && !currentUser.isActive) {
      context.go(AppRoutes.inactive);
      return;
    }

    if (!isBiometricAuth) {
      context.go(AppRoutes.biometric);
      return;
    }

    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Ícone do Launcher animado com sombra suave
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radius24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radius24),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback gracioso caso asset não seja encontrado
                          return Center(
                            child: Icon(
                              Icons.inventory_2_rounded,
                              size: 56,
                              color: colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const Gap(AppSpacing.space24),

                // Título e subtítulo da aplicação
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Estoque Pro',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Gap(AppSpacing.space4),
                      Text(
                        'Controle & Gestão Inteligente',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Barra de progresso com porcentagem e status
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radius8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: _progress),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          builder: (context, value, _) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppSpacing.radius8),
                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                            );
                          },
                        ),
                      ),
                      const Gap(AppSpacing.space8),
                      Text(
                        _statusText,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const Gap(AppSpacing.space32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
