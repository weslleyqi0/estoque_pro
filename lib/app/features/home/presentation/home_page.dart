import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/di/service_locator.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => getIt<AuthViewModel>().logoutCommand.execute(),
          ),
        ],
      ),
      body: Center(
        child: AppButton(
          onPressed: () => context.push(AppRoutes.users),
          label: 'Gerenciar Usuários',
        ),
      ),
    );
  }
}
