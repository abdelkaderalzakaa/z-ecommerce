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
        Padding(
          padding: const EdgeInsets.all(10),
          child: const Text(
            'المتابعات للمتجر',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        if (widget.store.followersUsers.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('لا يوجد متابعون لهذا المتجر حتى الآن.'),
            ),
          )
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
                    backgroundImage: follower.userAvatar != null && follower.userAvatar!.isNotEmpty
                        ? NetworkImage(follower.userAvatar!)
                        : null,
                    child: follower.userAvatar == null || follower.userAvatar!.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(follower.userName ?? 'مستخدم غير معروف'),
                  subtitle: Text(
                    'تاريخ المتابعة: ${follower.followedAt.toLocal().toString().split(' ')[0]}',
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
