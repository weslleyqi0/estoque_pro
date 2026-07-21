enum AppRole {
  owner('owner'),
  admin('admin'),
  seller('seller');

  final String value;
  const AppRole(this.value);

  static AppRole? fromValue(String value) {
    for (final role in values) {
      if (role.value == value) return role;
    }
    return null;
  }
}
