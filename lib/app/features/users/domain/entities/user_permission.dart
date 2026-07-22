enum UserPermission {
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
  manageStock(
    'manage_stock',
    'Gerenciar Estoque',
    'Permitir ajustar quantidades de estoque',
  ),
  manageSuppliers(
    'manage_suppliers',
    'Gerenciar Fornecedores',
    'Permitir adicionar, editar e remover fornecedores',
  ),
  manageUsers(
    'manage_users',
    'Gerenciar Usuários',
    'Permitir adicionar e editar outros usuários',
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
