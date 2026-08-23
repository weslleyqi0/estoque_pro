import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/core/router/app_routes.dart';
import 'package:estoque_pro/app/features/users/domain/entities/user_role.dart';
import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:estoque_pro/app/features/users/presentation/widgets/card_user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UsersPage extends StatefulWidget {
  final UsersViewModel Function() viewModelFactory;

  const UsersPage({
    super.key,
    required this.viewModelFactory,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final UsersViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModelFactory();
    viewModel.listenAllUsers();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        final currentUser = vm.currentUser;
        final currentUserRole = currentUser?.role ?? UserRole.seller;
        final currentUserId = currentUser?.uid ?? '';
        final canAddUser = currentUserRole == UserRole.owner || currentUserRole == UserRole.admin;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Gerenciar Usuários'),
          ),
          floatingActionButton: canAddUser
              ? AppFloatingActionButton(
                  tooltip: 'Adicionar funcionário',
                  icon: AppIcons.add,
                  onPressed: () => context.push(AppRoutes.userForm),
                )
              : null,
          body: Builder(
            builder: (context) {
              if (vm.state == UsersLoadState.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.state == UsersLoadState.failure) {
                return Center(child: Text(vm.error.toString()));
              }

              return ValueListenableBuilder(
                valueListenable: viewModel.expandedUserId,
                builder: (context, expandedId, child) {
                  return ListView.builder(
                    itemCount: vm.users.length,
                    padding: const EdgeInsets.only(bottom: AppSpacing.space80),
                    itemBuilder: (BuildContext context, int index) {
                      final user = vm.users[index];

                      return CardUser(
                        viewModel: vm,
                        user: user,
                        currentUserRole: currentUserRole,
                        currentUserId: currentUserId,
                        isExpanded: expandedId == user.uid,
                        onExpanded: () => viewModel.toggleExpanded(user.uid),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
