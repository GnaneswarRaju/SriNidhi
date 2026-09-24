import 'dart:async';

import 'package:hardware_store/core/errors/app_exception.dart';
import 'package:hardware_store/features/auth/domain/auth_repository.dart';
import 'package:hardware_store/features/workspace/domain/branch_membership.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user});
  StoreUser? user;
  bool failSignIn = false;
  final _events = StreamController<StoreUser?>.broadcast();
  @override
  Stream<StoreUser?> watchUser() async* {
    yield user;
    yield* _events.stream;
  }

  @override
  Future<void> signIn(String email, String password) async {
    if (failSignIn) throw const AppException(ErrorCode.authentication);
    user = StoreUser(id: 'user-a', email: email);
    _events.add(user);
  }

  @override
  Future<void> signOut() async {
    user = null;
    _events.add(null);
  }

  Future<void> close() => _events.close();
}

const testUser = StoreUser(id: 'user-a', email: 'test@example.com');
const branchA = BranchMembership(
  businessId: 'business-a',
  businessName: 'Test Hardware',
  branchId: 'branch-a',
  branchName: 'Main branch',
  branchCode: 'MAIN',
  roles: {StoreRole.cashier},
);
const branchB = BranchMembership(
  businessId: 'business-a',
  businessName: 'Test Hardware',
  branchId: 'branch-b',
  branchName: 'Second branch',
  branchCode: 'SECOND',
  roles: {StoreRole.manager},
);

class FakeWorkspaceRepository implements WorkspaceRepository {
  List<BranchMembership> branches = [branchA, branchB];
  bool fail = false;
  @override
  Future<List<BranchMembership>> memberships() async {
    if (fail) throw const AppException(ErrorCode.network);
    return branches;
  }
}
