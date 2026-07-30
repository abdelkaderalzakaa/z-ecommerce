import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class UserOverviewTab extends StatelessWidget {
  final UserModel user;

  const UserOverviewTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String roleText;
    switch (user.role) {
      case UserRole.superAdmin:
        roleText = TranslationKeys.superAdminRole.tr(context);
        break;
      case UserRole.companyOwner:
        roleText = TranslationKeys.storeOwnerRole.tr(context);
        break;
      case UserRole.customer:
        roleText = TranslationKeys.customerRole.tr(context);
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationKeys.accountInformation.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(
                    context,
                    TranslationKeys.user.tr(context),
                    user.name,
                    Icons.person_outline_rounded,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    TranslationKeys.email.tr(context),
                    user.email,
                    Icons.email_outlined,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    TranslationKeys.phone.tr(context),
                    user.phoneNumber ?? 'غير محدد',
                    Icons.phone_outlined,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    TranslationKeys.role.tr(context),
                    roleText,
                    Icons.admin_panel_settings_outlined,
                  ),
                  if (user.businessId != null) ...[
                    const Divider(),
                    _buildInfoRow(
                      context,
                      TranslationKeys.associatedStore.tr(context),
                      'متجر ${user.businessId}',
                      Icons.storefront_rounded,
                    ),
                  ],
                  const Divider(),
                  _buildInfoRow(
                    context,
                    TranslationKeys.joinedDate.tr(context),
                    '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
                    Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
