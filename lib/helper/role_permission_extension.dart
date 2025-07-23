extension RolePermissionExtension on String? {
  bool get isAdmin => this == 'admin';
  bool get isOperator => this == 'operator';
  bool get isOwner => this == 'owner';

  bool get canDelete => ['admin', 'operator'].contains(this);
  bool get canCreate => ['admin', 'operator'].contains(this);
}
