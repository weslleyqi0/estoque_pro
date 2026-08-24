import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String? address;
  final String? cpf;
  final String? phone;
  final bool isActive;

  const CustomerEntity({
    required this.id,
    required this.name,
    this.address,
    this.cpf,
    this.phone,
    this.isActive = true,
  });

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? address,
    String? cpf,
    String? phone,
    bool? isActive,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      cpf: cpf ?? this.cpf,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, address, cpf, phone, isActive];
}
