import 'package:estoque_pro/app/features/users/presentation/viewmodels/users_viewmodel.dart';
import 'package:estoque_pro/app/features/users/presentation/widgets/card_user.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  final UsersViewModel viewModel;

  const UsersPage({
    super.key,
    required this.viewModel,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.listenAllUsers();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Gerenciar Usuários'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;

          if (vm.state == UsersLoadState.loading) {
            return Center(child: CircularProgressIndicator());
          }

          if (vm.state == UsersLoadState.failure) {
            return Center(child: Text(vm.error.toString()));
          }

          return ValueListenableBuilder(
            valueListenable: widget.viewModel.expandedUserId,
            builder: (context, expandedId, child) {
              return ListView.builder(
                itemCount: vm.users.length,
                itemBuilder: (BuildContext context, int index) {
                  final user = vm.users[index];

                  return CardUser(
                    viewModel: vm,
                    user: user,
                    isExpanded: expandedId == user.uid,
                    onExpanded: () => widget.viewModel.toggleExpanded(user.uid),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
