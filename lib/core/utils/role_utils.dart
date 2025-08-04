class RoleUtils {
  static const List<String> _adminRoles = ['admin', 'teacher', 'cooperator'];

  /// Check if the user has admin-level permissions
  static bool isAdmin(String role) {
    return _adminRoles.contains(role.toLowerCase());
  }

  /// Get all admin-level roles
  static List<String> get adminRoles => List.unmodifiable(_adminRoles);

  /// Check if the user is a parent
  static bool isParent(String role) {
    return role.toLowerCase() == 'parent';
  }
}
