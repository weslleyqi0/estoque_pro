enum DeliveryStatus {
  pending('pending', 'Pendente'),
  inProgress('in_progress', 'Em andamento'),
  completed('completed', 'Finalizada'),
  delayed('delayed', 'Atrasada'),
  cancelled('cancelled', 'Cancelada');

  final String value;
  final String label;

  const DeliveryStatus(this.value, this.label);

  static DeliveryStatus fromValue(String? value) {
    for (final status in values) {
      if (status.value == value) return status;
    }
    return DeliveryStatus.pending;
  }
}
