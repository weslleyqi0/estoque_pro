import 'package:equatable/equatable.dart';

class ProductSupplierEntity extends Equatable {
  final String id;
  final String name;

  const ProductSupplierEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
