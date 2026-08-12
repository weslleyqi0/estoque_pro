import 'package:design_system/design_system.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/presentation/utils/category_icons.dart';
import 'package:estoque_pro/app/features/categories/presentation/viewmodels/categories_form_viewmodel.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CategoryFormPage extends StatefulWidget {
  final CategoriesFormViewmodel viewModel;
  final CategoryEntity? category;

  const CategoryFormPage({
    super.key,
    required this.viewModel,
    this.category,
  });

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  CategoryEntity? _currentCategory;

  String _selectedIcon = 'category';
  Color _selectedColor = Colors.transparent; // Use transparent to fallback to primary later

  bool get _isEditing => _currentCategory != null;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category;
    _nameController = TextEditingController(text: _currentCategory?.name ?? '');
    _selectedIcon = _currentCategory?.icon ?? 'category';

    if (_currentCategory?.color != null) {
      _selectedColor = Color(_currentCategory!.color!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final category = CategoryEntity(
      id: _currentCategory?.id ?? '',
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor == Colors.transparent ? null : _selectedColor.toARGB32(),
    );

    if (_isEditing) {
      await widget.viewModel.updateCategoryCommand.execute(category);
      if (widget.viewModel.updateCategoryCommand.isSuccess && mounted) {
        Navigator.pop(context);
      }
    } else {
      await widget.viewModel.saveCategoryCommand.execute(category);
      if (widget.viewModel.saveCategoryCommand.isSuccess && mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _delete() async {
    if (_currentCategory == null) return;

    await widget.viewModel.deleteCategoryCommand.execute(_currentCategory!.id);

    if (widget.viewModel.deleteCategoryCommand.isSuccess && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickColor() async {
    final Color newColor = await showColorPickerDialog(
      context,
      _selectedColor == Colors.transparent ? context.colorScheme.primary : _selectedColor,
      title: Text('Selecione uma cor', style: context.textTheme.titleLarge),
      width: 40,
      height: 40,
      spacing: 0,
      runSpacing: 0,
      borderRadius: 20,
      wheelDiameter: 250,
      wheelWidth: 30,
      enableOpacity: false,
      showColorCode: true,
      colorCodeHasColor: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
    );

    setState(() {
      _selectedColor = newColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEditing ? 'Editar Categoria' : 'Nova Categoria'),
        actions: [
          AppIconButton(
            icon: AppIcons.save,
            onPressed: () => _save(),
          ),
          if (_currentCategory != null)
            AppIconButton(
              icon: AppIcons.delete,
              onPressed: () => _delete(),
            ),
          const Gap(AppSpacing.space4),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextfield(
                    label: 'Nome',
                    hint: 'Nome da categoria',
                    required: true,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const Gap(AppSpacing.space24),

                  Text('Cor (Opcional)', style: context.textTheme.labelLarge),
                  const Gap(AppSpacing.space8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _selectedColor == Colors.transparent
                          ? context.colorScheme.primary
                          : _selectedColor,
                    ),
                    title: const Text('Selecionar cor'),
                    subtitle: Text(_selectedColor == Colors.transparent ? 'Padrão do sistema' : 'Cor personalizada'),
                    trailing: _selectedColor != Colors.transparent
                        ? IconButton(
                            icon: const Icon(AppIcons.close),
                            onPressed: () => setState(() => _selectedColor = Colors.transparent),
                          )
                        : null,
                    onTap: _pickColor,
                  ),
                  const Gap(AppSpacing.space24),

                  Text('Ícone', style: context.textTheme.labelLarge),
                  const Gap(AppSpacing.space8),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                child: AppIconPicker(
                  icons: CategoryIcons.icons,
                  selectedIcon: _selectedIcon,
                  onIconSelected: (key) => setState(() => _selectedIcon = key),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.space16),
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  widget.viewModel.saveCategoryCommand,
                  widget.viewModel.updateCategoryCommand,
                ]),
                builder: (context, _) {
                  final isLoading =
                      widget.viewModel.saveCategoryCommand.isRunning ||
                      widget.viewModel.updateCategoryCommand.isRunning;
                  return AppButton.primary(
                    label: _isEditing ? 'Salvar Alterações' : 'Salvar Categoria',
                    isFullWidth: true,
                    isLoading: isLoading,
                    onPressed: _save,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
