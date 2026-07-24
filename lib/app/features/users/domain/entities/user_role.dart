enum UserRole {
  owner('owner', 'Dono'),
  admin('admin', 'Admin'),
  seller('seller', 'Vendedor');

  final String value;
  final String title;

  const UserRole(
    this.value,
    this.title,
  );

  static UserRole? fromValue(String value) {
    for (final role in values) {
      if (role.value == value) return role;
    }
    return null;
  }
}
