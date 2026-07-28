import 'package:estoque_pro/app/features/suppliers/domain/entities/supplier_entity.dart';

class SupplierModel {
  final String id;
  final String name;
  final String? cnpj;
  final String? phone;
  final bool isActive;

  const SupplierModel({
    required this.id,
    required this.name,
    this.cnpj,
    this.phone,
    this.isActive = true,
  });

  factory SupplierModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return SupplierModel(
      id: id,
      name: map['name'] as String? ?? '',
      cnpj: map['cnpj'] as String?,
      phone: map['phone'] as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cnpj': cnpj,
      'phone': phone,
      'isActive': isActive,
    };
  }

  SupplierEntity toEntity() {
    return SupplierEntity(
      id: id,
      name: name,
      cnpj: cnpj,
      phone: phone,
      isActive: isActive,
    );
  }

  factory SupplierModel.fromEntity(SupplierEntity entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      cnpj: entity.cnpj,
      phone: entity.phone,
      isActive: entity.isActive,
    );
  }
}
