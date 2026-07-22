enum UserRole {
  owner('owner'),
  admin('admin'),
  seller('seller');

  final String value;
  const UserRole(this.value);

  static UserRole? fromValue(String value) {
    for (final role in values) {
      if (role.value == value) return role;
    }
    return null;
  }
}
