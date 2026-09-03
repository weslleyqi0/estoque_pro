import 'package:equatable/equatable.dart';

class UpdateDeliveryCustomerDto extends Equatable {
  final String saleId;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerAddress;
  final String? saleNumber;

  const UpdateDeliveryCustomerDto({
    required this.saleId,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.saleNumber,
  });

  @override
  List<Object?> get props => [
        saleId,
        customerId,
        customerName,
        customerPhone,
        customerAddress,
        saleNumber,
      ];
}
