import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/delete_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/save_category_use_case.dart';
import 'package:estoque_pro/app/features/categories/domain/usecases/update_category_use_case.dart';

class CategoriesFormViewmodel extends BaseViewModel {
  final SaveCategoryUseCase _saveCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  late final Command1<bool, CategoryEntity> saveCategoryCommand;
  late final Command1<bool, CategoryEntity> updateCategoryCommand;
  late final Command1<bool, String> deleteCategoryCommand;

  CategoriesFormViewmodel(
    this._saveCategoryUseCase,
    this._updateCategoryUseCase,
    this._deleteCategoryUseCase,
  ) {
    saveCategoryCommand = Command1((category) => _saveCategoryUseCase(category));
    updateCategoryCommand = Command1((category) async {
      final result = await _updateCategoryUseCase(category);
      notifyListeners();
      return result;
    });
    deleteCategoryCommand = Command1((id) => _deleteCategoryUseCase(id));
  }
}
