import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import '../../global/core/constants/app_constants.dart';
import '../../global/core/responsive/responsive_layout.dart';
import '../../global/translate/app_localizations.dart';
import '../../global/translate/translation_keys.dart';

class NewsletterSection extends StatefulWidget {
  const NewsletterSection({super.key});

  @override
  State<NewsletterSection> createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends State<NewsletterSection> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 80),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 28 : 64,
          vertical: isMobile ? 48 : 56,
        ),
        decoration: BoxDecoration(
          color: AppColors.newsletterBg,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: isMobile
            ? _MobileNewsletter(emailController: _emailController)
            : _DesktopNewsletter(emailController: _emailController),
      ),
    );
  }
}

class _DesktopNewsletter extends StatelessWidget {
  final TextEditingController emailController;
  const _DesktopNewsletter({required this.emailController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 5, child: _NewsletterTitle(isMobile: false)),
        const SizedBox(width: 48),
        Expanded(
          flex: 5,
          child: _NewsletterForm(emailController: emailController),
        ),
      ],
    );
  }
}

class _MobileNewsletter extends StatelessWidget {
  final TextEditingController emailController;
  const _MobileNewsletter({required this.emailController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NewsletterTitle(isMobile: true),
        const SizedBox(height: 32),
        _NewsletterForm(emailController: emailController),
      ],
    );
  }
}

class _NewsletterTitle extends StatelessWidget {
  final bool isMobile;
  const _NewsletterTitle({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Text(
      TranslationKeys.stayUptoDate.tr(context),
      style: TextStyle(
        fontSize: isMobile ? 28 : 40,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        height: 1.15,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _NewsletterForm extends StatelessWidget {
  final TextEditingController emailController;

  const _NewsletterForm({required this.emailController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmailInput(controller: emailController),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ButtonApp(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      TranslationKeys.subscribedSuccessfully.tr(context),
                    ),
                  ),
                );
                emailController.clear();
              }
            },
            label: TranslationKeys.subscribeToNewsletter.tr(context),
          ),
        ),
      ],
    );
  }
}

class _EmailInput extends StatelessWidget {
  final TextEditingController controller;
  const _EmailInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        hintText: TranslationKeys.enterYourEmail.tr(context),
        prefixIcon: const Icon(Icons.email_outlined, size: 20),
      ),
    );
  }
}
