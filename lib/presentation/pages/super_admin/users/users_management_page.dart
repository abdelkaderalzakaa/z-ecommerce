import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/super_admin_provider.dart';
import 'package:z_ecommerce/data/services/user_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/users/user_details_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/users/create_edit_user_page.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  List<UserModel> _allFetchedUsers = [];
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';
  List<UserModel> _selectedUsers = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _userService.getAllUsers();
    if (mounted) {
      setState(() {
        _allFetchedUsers = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('إدارة المستخدمين')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List<UserModel> allUsers = _allFetchedUsers;

    final filteredUsers = allUsers.where((user) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole =
          _selectedRoleFilter == 'all' ||
          user.role.name.toLowerCase() == _selectedRoleFilter.toLowerCase();

      return matchesQuery && matchesRole;
    }).toList();

    final totalItems = filteredUsers.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
    final paginatedUsers = (startIndex < totalItems)
        ? filteredUsers.sublist(startIndex, endIndex)
        : <UserModel>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.usersManagement.tr(context),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إدارة ومتابعة كافة الحسابات والعملاء والمشرفين المسجلين',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      changeScreen(context, const CreateEditUserPage()),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(TranslationKeys.addNewUser.tr(context)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Full Height Expanded AppDataTable for UserModel
            Expanded(
              child: AppDataTable<UserModel>(
                items: paginatedUsers,
                selectable: true,
                showIndexColumn: true,
                selectedItems: _selectedUsers,
                onSelectionChanged: (selected) {
                  setState(() {
                    _selectedUsers = selected;
                  });
                },
                onBulkDelete: () {
                  setState(() {
                    _selectedUsers.clear();
                  });
                },
                searchQuery: _searchQuery,
                onSearchChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _currentPage = 1;
                  });
                },
                onFilterTap: () => _showFilterDialog(context),
                currentPage: _currentPage,
                totalPages: totalPages > 0 ? totalPages : 1,
                totalItems: totalItems,
                itemsPerPage: _itemsPerPage,
                onPageChanged: (page) => setState(() => _currentPage = page),
                onItemsPerPageChanged: (rows) {
                  setState(() {
                    _itemsPerPage = rows;
                    _currentPage = 1;
                  });
                },
                emptyMessage: _searchQuery.isNotEmpty
                    ? TranslationKeys.noMatchingResults.tr(context)
                    : TranslationKeys.noDataAvailable.tr(context),
                onRowTap: (user) =>
                    changeScreen(context, UserDetailsPage(userId: user.id)),
                columns: [
                  AppTableColumn<UserModel>(
                    title: TranslationKeys.user.tr(context),
                    flex: 2,
                    sortable: true,
                    sortKey: (u) => u.name,
                    cellBuilder: (u) => TableImageTextCell(
                      title: u.name,
                      subtitle: u.email,
                      imageUrl: u.avatarUrl,
                      fallbackIcon: Icons.person_outline_rounded,
                    ),
                  ),
                  AppTableColumn<UserModel>(
                    title: TranslationKeys.role.tr(context),
                    flex: 1,
                    sortable: true,
                    sortKey: (u) => u.role.name,
                    cellBuilder: (u) {
                      String roleLabel;
                      Color bg;
                      Color fg;

                      switch (u.role) {
                        case UserRole.superAdmin:
                          roleLabel = TranslationKeys.superAdminRole.tr(
                            context,
                          );
                          bg = const Color(0xFFEEF2FF);
                          fg = const Color(0xFF4F46E5);
                          break;
                        case UserRole.businessOwner:
                          roleLabel = TranslationKeys.storeOwnerRole.tr(
                            context,
                          );
                          bg = const Color(0xFFFEF3C7);
                          fg = const Color(0xFFD97706);
                          break;
                        case UserRole.customer:
                          roleLabel = TranslationKeys.customerRole.tr(context);
                          bg = const Color(0xFFE6F4EA);
                          fg = const Color(0xFF137333);
                          break;
                      }

                      return TableStatusBadge(
                        statusText: roleLabel,
                        backgroundColor: bg,
                        textColor: fg,
                      );
                    },
                  ),
                  AppTableColumn<UserModel>(
                    title: TranslationKeys.joinedDate.tr(context),
                    flex: 1,
                    sortable: true,
                    sortKey: (u) => u.createdAt,
                    cellBuilder: (u) => TableTextCell(
                      title:
                          '${u.createdAt.year}-${u.createdAt.month.toString().padLeft(2, '0')}-${u.createdAt.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                  AppTableColumn<UserModel>(
                    title: TranslationKeys.statusActive.tr(context),
                    flex: 1,
                    cellBuilder: (u) => TableStatusBadge.fromStatus(
                      TranslationKeys.statusActive.tr(context),
                    ),
                  ),
                  AppTableColumn<UserModel>(
                    title: TranslationKeys.actions.tr(context),
                    width: 70,
                    alignment: Alignment.center,
                    cellBuilder: (u) => TablePopupMenuActions(
                      onView: () =>
                          changeScreen(context, UserDetailsPage(userId: u.id)),
                      onEdit: () =>
                          changeScreen(context, CreateEditUserPage(user: u)),
                      onDelete: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم حذف حساب المستخدم "${u.name}" بنجاح',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationKeys.filter.tr(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(TranslationKeys.allProducts.tr(context)),
              value: 'all',
              groupValue: _selectedRoleFilter,
              onChanged: (val) {
                setState(() => _selectedRoleFilter = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(TranslationKeys.superAdminRole.tr(context)),
              value: 'superAdmin',
              groupValue: _selectedRoleFilter,
              onChanged: (val) {
                setState(() => _selectedRoleFilter = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(TranslationKeys.storeOwnerRole.tr(context)),
              value: 'businessOwner',
              groupValue: _selectedRoleFilter,
              onChanged: (val) {
                setState(() => _selectedRoleFilter = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(TranslationKeys.customerRole.tr(context)),
              value: 'customer',
              groupValue: _selectedRoleFilter,
              onChanged: (val) {
                setState(() => _selectedRoleFilter = val!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
