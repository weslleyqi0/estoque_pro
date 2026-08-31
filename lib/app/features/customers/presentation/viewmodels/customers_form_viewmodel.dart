import 'package:estoque_pro/app/core/base/base_viewmodel.dart';
import 'package:estoque_pro/app/core/utils/command.dart';
import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/delete_customer_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/save_customer_use_case.dart';
import 'package:estoque_pro/app/features/customers/domain/usecases/update_customer_use_case.dart';

class CustomersFormViewModel extends BaseViewModel {
  final SaveCustomerUseCase _saveCustomerUseCase;
  final UpdateCustomerUseCase _updateCustomerUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;

  late final Command1<bool, CustomerEntity> saveCustomerCommand;
  late final Command1<bool, CustomerEntity> updateCustomerCommand;
  late final Command1<bool, String> deleteCustomerCommand;

  CustomersFormViewModel(
    this._saveCustomerUseCase,
    this._updateCustomerUseCase,
    this._deleteCustomerUseCase,
  ) {
    saveCustomerCommand = Command1((customer) => _saveCustomerUseCase(customer));
    updateCustomerCommand = Command1((customer) async {
      final result = await _updateCustomerUseCase(customer);
      notifyListeners();
      return result;
    });
    deleteCustomerCommand = Command1((id) => _deleteCustomerUseCase(id));
  }
}
