import 'dart:async';

import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/categories/domain/entities/category_entity.dart';
import 'package:estoque_pro/app/features/categories/domain/repositories/categories_repository.dart';
import 'package:flutter/foundation.dart';

class CategoriesFormViewmodel extends ChangeNotifier {
  final CategoriesRepository _repository;

  late final Command1<bool, CategoryEntity> saveCategoryCommand;
  late final Command1<bool, CategoryEntity> updateCategoryCommand;
  late final Command1<bool, String> deleteCategoryCommand;

  Object? _error;
  Object? get error => _error;

  CategoriesFormViewmodel(this._repository) {
    saveCategoryCommand = Command1(_saveCategory);
    updateCategoryCommand = Command1(_updateCategory);
    deleteCategoryCommand = Command1(_deleteCategory);
  }

  Future<Result<bool>> _saveCategory(CategoryEntity category) async {
    try {
      await _repository.save(category);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _updateCategory(CategoryEntity category) async {
    try {
      await _repository.update(category);
      notifyListeners();
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }

  Future<Result<bool>> _deleteCategory(String id) async {
    try {
      await _repository.delete(id);
      return const Success(true);
    } catch (e) {
      return Failure(Exception(e.toString()));
    }
  }
}
