enum UserPermission {
  editProducts(
    'edit_products',
    'Editar Produtos',
    'Permitir editar informações de produtos existentes',
  ),
  deleteProducts(
    'delete_products',
    'Excluir Produtos',
    'Permitir remover produtos do sistema',
  ),
  manageStock(
    'manage_stock',
    'Gerenciar Estoque',
    'Permitir ajustar quantidades de estoque',
  ),
  viewHistory(
    'view_history',
    'Ver Histórico de Estoque',
    'Permitir visualizar o histórico de movimentações de estoque dos produtos',
  ),
  manageCategories(
    'manage_categories',
    'Gerenciar Categorias',
    'Permitir adicionar, editar e remover categorias de produtos',
  ),
  manageSuppliers(
    'manage_suppliers',
    'Gerenciar Fornecedores',
    'Permitir adicionar, editar e remover fornecedores',
  ),
  managerCustomer(
    'manage_customer',
    'Gerenciar Clientes',
    'Permitir adicionar, editar e remover clientes',
  ),
  editSales(
    'edit_sales',
    'Editar Vendas',
    'Permitir alterar vendas já finalizadas (trocas, devoluções, correções)',
  ),
  cancelCompletedSales(
    'cancel_completed_sales',
    'Cancelar Vendas Concluídas',
    'Permitir cancelar vendas que já foram finalizadas',
  ),
  deleteSales(
    'delete_sales',
    'Excluir Vendas de Outros',
    'Permitir cancelar e excluir vendas em andamento de outros vendedores',
  ),
  changeSalePrice(
    'change_sale_price',
    'Alterar Preço na Venda',
    'Permitir mudar o preço dos produtos durante a venda',
  ),
  viewSalesHistory(
    'view_sales_history',
    'Ver Histórico de Edição de Vendas',
    'Permitir visualizar o histórico de edições de vendas',
  ),
  deliveries(
    'deliveries',
    'Entregas',
    'Gerenciar entregas',
  ),
  viewReports(
    'view_reports',
    'Ver Relatórios',
    'Permitir acessar relatórios e estatísticas',
  );

  final String value;
  final String title;
  final String description;

  const UserPermission(this.value, this.title, this.description);

  static UserPermission? fromValue(String value) {
    for (final perm in values) {
      if (perm.value == value) return perm;
    }
    return null;
  }
}
