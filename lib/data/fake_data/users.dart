import '../models/user_model.dart';
import '../models/address_model.dart';

final List<UserModel> fakeUsers = [
  // Super Admin
  UserModel(
    id: 'user_admin',
    name: 'Platform Admin',
    email: 'admin@shop.com',
    role: UserRole.superAdmin,
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
  ),

  // Company Owner 1
  UserModel(
    id: 'user_owner_001',
    name: 'Owner One',
    email: 'owner@cmp1.com',
    role: UserRole.companyOwner,
    companyId: 'cmp_001',
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
  ),

  // Company Owner 2
  UserModel(
    id: 'user_owner_002',
    name: 'Owner Two',
    email: 'owner@cmp2.com',
    role: UserRole.companyOwner,
    companyId: 'cmp_002',
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
  ),

  // Customer
  UserModel(
    id: 'user_customer_001',
    name: 'Sarah Jenkins',
    email: 'sarah@example.com',
    role: UserRole.customer,
    phoneNumber: '+1 234 567 8900',
    avatarUrl: null,
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
    addresses: [
      AddressModel(
        label: 'Home',
        street: '123 Main Street, Apt 4B',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'USA',
      ),
    ],
    wishlist: ['prod_1', 'prod_4', 'prod_7'],
  ),
];

// Helper to authenticate against fake users (mocking a DB check)
UserModel? authenticateFakeUser(String email, String password) {
  if (password != 'password123') return null;

  try {
    final user = fakeUsers.firstWhere((user) => user.email.toLowerCase() == email.toLowerCase());
    return user;
  } catch (e) {
    return null;
  }
}
