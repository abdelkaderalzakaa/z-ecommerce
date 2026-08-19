import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import '../../super_admin/business/business_details_tab/followers_tab.dart';

class StoreFollowersPage extends StatelessWidget {
  const StoreFollowersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<BusinessProvider>().selectedBusiness;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: FollowersTab(store: store),
      ),
    );
  }
}
