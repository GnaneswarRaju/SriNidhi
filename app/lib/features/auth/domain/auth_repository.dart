class StoreUser {
  const StoreUser({required this.id, required this.email});
  final String id;
  final String email;
}

abstract interface class AuthRepository {
  Stream<StoreUser?> watchUser();
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}
