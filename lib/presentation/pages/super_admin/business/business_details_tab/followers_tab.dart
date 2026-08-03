import 'package:flutter/material.dart';

import 'package:z_ecommerce/data/models/store/business_model.dart';

class FollowersTab extends StatefulWidget {
  final BusinessModel store;

  const FollowersTab({super.key, required this.store});

  @override
  State<FollowersTab> createState() => _FollowersTabState();
}

class _FollowersTabState extends State<FollowersTab> {
  bool followersEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'المتابعات للمتجر',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Text('تفعيل المتابعات'),
                Switch(
                  value: followersEnabled,
                  onChanged: (val) {
                    setState(() {
                      followersEnabled = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(val ? 'تم تفعيل ميزة المتابعات' : 'تم إيقاف ميزة المتابعات')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.store.followersUsers.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('لا يوجد متابعون لهذا المتجر حتى الآن.'),
          ))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.store.followersUsers.length,
            itemBuilder: (context, index) {
              final follower = widget.store.followersUsers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: follower.userAvatar != null ? NetworkImage(follower.userAvatar!) : null,
                    child: follower.userAvatar == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(follower.userName ?? 'مستخدم غير معروف'),
                  subtitle: Text('تاريخ المتابعة: ${follower.followedAt.toLocal().toString().split(' ')[0]}'),
                ),
              );
            },
          ),
      ],
    );
  }
}
