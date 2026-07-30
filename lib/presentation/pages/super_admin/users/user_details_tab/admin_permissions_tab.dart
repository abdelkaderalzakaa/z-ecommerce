import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/auth/user_model.dart';

class AdminPermissionsTab extends StatelessWidget {
  final UserModel user;

  const AdminPermissionsTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الصلاحيات الإدارية وسجل النطاق',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: theme.primaryColor),
                      const SizedBox(width: 10),
                      const Text(
                        'صلاحيات المسؤول الأكبر (Super Admin)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildPermissionItem('إدارة المتاجر والاعتمادات', true),
                  const Divider(),
                  _buildPermissionItem('إدارة المنتجات والأقسام العامة', true),
                  const Divider(),
                  _buildPermissionItem('إدارة الطلبات والمالية الشاملة', true),
                  const Divider(),
                  _buildPermissionItem('إدارة المستخدمين والأدوار', true),
                  const Divider(),
                  _buildPermissionItem('إعدادات المنصة والهوية', true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String title, bool isGranted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Icon(
                isGranted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isGranted ? Colors.green : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                isGranted ? 'مفعلة' : 'غير مفعلة',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isGranted ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
