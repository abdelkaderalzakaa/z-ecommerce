import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/widgets/common/headers/header_auth.dart';
import '../../../data/providers/company_provider.dart';
import '../../widgets/common/headers/header_home.dart';
import '../../widgets/common/footer_section.dart';
import '../../widgets/auth/success_widget.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';

class AuthSuccessPage extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;

  const AuthSuccessPage({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderAuth(title: title),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SuccessWidget(
              message: message,
              buttonLabel: buttonLabel,
              onPressed: () {
                changeScreen(context, const LoginPage());
              },
            ),
          ],
        ),
      ),
    );
  }
}
