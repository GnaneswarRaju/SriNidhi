enum StoreRole {
  owner,
  admin,
  manager,
  cashier,
  stockManager,
  accountant;

  static StoreRole fromDatabase(String value) => switch (value) {
    'OWNER' => owner,
    'ADMIN' => admin,
    'MANAGER' => manager,
    'CASHIER' => cashier,
    'STOCK_MANAGER' => stockManager,
    'ACCOUNTANT' => accountant,
    _ => throw const FormatException('Unknown role'),
  };
}

class BranchMembership {
  const BranchMembership({
    required this.businessId,
    required this.businessName,
    required this.branchId,
    required this.branchName,
    required this.branchCode,
    required this.roles,
  });
  final String businessId;
  final String businessName;
  final String branchId;
  final String branchName;
  final String branchCode;
  final Set<StoreRole> roles;

  factory BranchMembership.fromJson(Map<String, dynamic> json) =>
      BranchMembership(
        businessId: json['business_id'] as String,
        businessName: json['business_name'] as String,
        branchId: json['branch_id'] as String,
        branchName: json['branch_name'] as String,
        branchCode: json['branch_code'] as String,
        roles: Set.unmodifiable(
          (json['roles'] as List).cast<String>().map(StoreRole.fromDatabase),
        ),
      );
}

abstract interface class WorkspaceRepository {
  Future<List<BranchMembership>> memberships();
}
