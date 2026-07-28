import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final String id;
  final String name;
  final String? cnpj;
  final String? phone;
  final bool isActive;

  const SupplierEntity({
    required this.id,
    required this.name,
    this.cnpj,
    this.phone,
    this.isActive = true,
  });

  SupplierEntity copyWith({
    String? id,
    String? name,
    String? cnpj,
    String? phone,
    String? email,
    String? address,
    bool? isActive,
  }) {
    return SupplierEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, cnpj, phone, isActive];
}
