import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/delete_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/save_supplier_use_case.dart';
import 'package:estoque_pro/app/features/suppliers/domain/usecases/update_supplier_use_case.dart';

class SuppliersFormViewmodel extends BaseViewModel {
  final SaveSupplierUseCase _saveSupplierUseCase;
  final UpdateSupplierUseCase _updateSupplierUseCase;
  final DeleteSupplierUseCase _deleteSupplierUseCase;

  late final Command1<bool, SupplierEntity> saveSupplierCommand;
  late final Command1<bool, SupplierEntity> updateSupplierCommand;
  late final Command1<bool, String> deleteSupplierCommand;

  SuppliersFormViewmodel(
    this._saveSupplierUseCase,
    this._updateSupplierUseCase,
    this._deleteSupplierUseCase,
  ) {
    saveSupplierCommand = Command1((supplier) => _saveSupplierUseCase(supplier));
    updateSupplierCommand = Command1((supplier) async {
      final result = await _updateSupplierUseCase(supplier);
      notifyListeners();
      return result;
    });
    deleteSupplierCommand = Command1((id) => _deleteSupplierUseCase(id));
  }
}
