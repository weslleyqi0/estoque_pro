import 'package:estoque_pro/app/features/customers/domain/entities/customer_entity.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? address;
  final String? cpf;
  final String? phone;
  final bool isActive;

  const CustomerModel({
    required this.id,
    required this.name,
    this.address,
    this.cpf,
    this.phone,
    this.isActive = true,
  });

  factory CustomerModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return CustomerModel(
      id: id,
      name: map['name'] as String? ?? '',
      address: map['address'] as String?,
      cpf: map['cpf'] as String?,
      phone: map['phone'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (cpf != null && cpf!.isNotEmpty) 'cpf': cpf,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      'is_active': isActive,
    };
  }

  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      name: name,
      address: address,
      cpf: cpf,
      phone: phone,
      isActive: isActive,
    );
  }

  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      cpf: entity.cpf,
      phone: entity.phone,
      isActive: entity.isActive,
    );
  }
}
