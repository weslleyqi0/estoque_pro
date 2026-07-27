enum UserPermission {
  editProducts(
    'edit_products',
    'Editar Produtos',
    'Permitir editar informações de produtos existentes',
  ),
  editSales(
    'edit_sales',
    'Editar Vendas',
    'Permitir alterar vendas já finalizadas (trocas, devoluções, correções)',
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
  viewReports(
    'view_reports',
    'Ver Relatórios',
    'Permitir acessar relatórios e estatísticas',
  ),
  deliveries(
    'deliveries',
    'Entregas',
    'Gerenciar entregas',
  ),

  changeSalePrice(
    'change_sale_price',
    'Alterar Preço na Venda',
    'Permitir mudar o preço dos produtos durante a venda',
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
