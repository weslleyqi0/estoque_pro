enum SaleStatus {
  inProgress('in_progress', 'Em andamento'),
  completed('completed', 'Concluída'),
  cancelled('cancelled', 'Cancelada'),
  returned('returned', 'Devolvida'),
  exchanged('exchanged', 'Trocada'),
  corrected('corrected', 'Corrigida'),
  edited('edited', 'Editada');

  final String value;
  final String label;

  const SaleStatus(this.value, this.label);

  bool get isEdited => this == SaleStatus.edited;

  static SaleStatus fromValue(String? value) {
    for (final status in values) {
      if (status.value == value) return status;
    }
    return SaleStatus.completed;
  }
}
