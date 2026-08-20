enum PaymentMethod {
  dinheiro('dinheiro', 'Dinheiro'),
  pix('pix', 'PIX'),
  fiado('fiado', 'Fiado'),
  credito('credito', 'Crédito'),
  debito('debito', 'Débito');

  final String value;
  final String label;

  const PaymentMethod(this.value, this.label);

  static PaymentMethod? fromValue(String? value) {
    for (final method in values) {
      if (method.value == value) return method;
    }
    return null;
  }
}
