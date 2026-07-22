import '../models/user_model.dart';
import '../models/address_model.dart';

final List<UserModel> fakeUsers = [
  UserModel(
    id: 'user_001',
    name: 'Sarah Jenkins',
    email: 'sarah@example.com',
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
      AddressModel(
        label: 'Office',
        street: '456 Business Blvd, Floor 12',
        city: 'New York',
        state: 'NY',
        zipCode: '10002',
        country: 'USA',
      ),
    ],
    wishlist: ['prod_1', 'prod_4', 'prod_7'], // Assuming these IDs might match fakeProducts later
    storeIds: ['cmp_001', 'cmp_002'], // This user has access to both stores
  ),
  UserModel(
    id: 'user_002',
    name: 'Michael Chen',
    email: 'michael.c@example.com',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    addresses: [],
    wishlist: [],
    storeIds: ['cmp_001'], // This user has access to only one store
  ),
];

// Helper to authenticate against fake users (mocking a DB check)
UserModel? authenticateFakeUser(String email, String password) {
  // In a real app we'd hash and check passwords.
  // Here we just check if the email matches a fake user.
  // We'll assume the password must be "password123" for fake users.
  if (password != 'password123') return null;

  try {
    return fakeUsers.firstWhere((user) => user.email.toLowerCase() == email.toLowerCase());
  } catch (e) {
    return null;
  }
}
