enum UserRole {
  superAdmin,
  admin,
  dealer,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.admin:
        return 'admin';
      case UserRole.dealer:
        return 'dealer';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
      case 'super-admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'dealer':
        return UserRole.dealer;
      default:
        return UserRole.admin;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.dealer:
        return 'Dealer';
    }
  }

  bool get isStaff => this == UserRole.superAdmin || this == UserRole.admin;
}
