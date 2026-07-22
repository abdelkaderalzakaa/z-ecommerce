import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/providers/invoice_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/company_provider.dart';
import '../../data/models/address_model.dart';
import '../../data/models/company_settings_model.dart';
import '../global/core/constants/app_constants.dart';
import '../global/core/responsive/responsive_layout.dart';
import '../widgets/common/headers/header_details.dart';
import '../widgets/common/footer_section.dart';
import '../widgets/cart/order_summary.dart';
import '../widgets/cart/cart_item.dart';
import '../widgets/common/headers/widgets/top_title.dart';
import '../widgets/profile/tabs/widgets/address_form_dialog.dart';
import '../global/translate/app_localizations.dart';
import '../global/translate/translation_keys.dart';
import '../global/router/app_routes.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final List<AddressModel> _selectedAddresses = [];
  PaymentMethodType? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        final addresses = authProvider.currentUser?.addresses ?? [];
        if (addresses.isNotEmpty) {
          setState(() {
            _selectedAddresses.add(addresses.first);
          });
        }
      }

      final companyProvider = context.read<CompanyProvider>();
      final methods =
          companyProvider.companySettings?.paymentMethods ?? [PaymentMethodType.cod];
      if (methods.isNotEmpty) {
        setState(() {
          _selectedPaymentMethod = methods.first;
        });
      }
    });
  }

  void _submitOrder() {
    final cartProvider = context.read<CartProvider>();
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TranslationKeys.loginToPlaceOrder.tr(context),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final companyId =
        context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001';

    if (cartProvider.items(companyId).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationKeys.yourCartIsEmpty.tr(context))),
      );
      return;
    }

    if (_selectedAddresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TranslationKeys.selectShippingAddress.tr(context),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final invoiceProvider = context.read<InvoiceProvider>();

    final subtotal = cartProvider.subTotal(companyId);
    final discount = subtotal * 0.20;
    final shipping = subtotal > 0 ? 15.0 : 0.0;

    List<String> generatedInvoiceIds = [];

    for (var address in _selectedAddresses) {
      invoiceProvider.generateInvoice(
        storeId: companyId,
        items: cartProvider.items(companyId),
        discount: discount,
        tax: 0,
        shippingCost: shipping,
        shippingAddress: address,
      );
      generatedInvoiceIds.add(invoiceProvider.invoices.last.invoiceId);
    }

    cartProvider.clearCart(companyId);

    _showSuccessDialog(generatedInvoiceIds);
  }

  void _showSuccessDialog(List<String> invoiceIds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text(
              TranslationKeys.orderPlacedSuccessfully.tr(context),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        content: Text(
          '${TranslationKeys.thankYouForPurchase.tr(context)}${invoiceIds.map((id) => '• $id').join('\n')}',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final cid =
                  context.read<CompanyProvider>().companySettings?.id ??
                  'cmp_001';
              Navigator.of(context).pop();
              context.go(AppRoutes.toHome(cid));
            },
            child: Text(TranslationKeys.backToHome.tr(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.checkoutTitle.tr(context),
        fallbackRoute: AppRoutes.toCart(
          context.read<CompanyProvider>().companySettings?.id ?? 'cmp_001',
        ),
        paths: [
          TranslationKeys.home.tr(context),
          TranslationKeys.yourCart.tr(context),
          TranslationKeys.checkout.tr(context),
        ],
        isCartActive: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: isMobile
                  ? Column(
                      children: [
                        _buildUserSection(),
                        const SizedBox(height: 24),
                        _buildAddressSection(),
                        const SizedBox(height: 32),
                        _buildPaymentMethodsSection(),
                        const SizedBox(height: 24),
                        OrderSummary(
                          isCheckoutPage: true,
                          onCheckout: _submitOrder,
                          multiplier: _selectedAddresses.isEmpty
                              ? 1
                              : _selectedAddresses.length,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              _buildUserSection(),
                              const SizedBox(height: 24),
                              _buildAddressSection(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildPaymentMethodsSection(),
                              const SizedBox(height: 24),
                              OrderSummary(
                                isCheckoutPage: true,
                                onCheckout: _submitOrder,
                                multiplier: _selectedAddresses.isEmpty
                                    ? 1
                                    : _selectedAddresses.length,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 80),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return _buildSectionContainer(
            title: TranslationKeys.customerInformation.tr(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TranslationKeys.checkingOutAsGuest.tr(context),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.go(AppRoutes.toLogin());
                  },
                  child: Text(TranslationKeys.login.tr(context)),
                ),
              ],
            ),
          );
        }

        final user = authProvider.currentUser!;
        return _buildSectionContainer(
          title: TranslationKeys.customerInformation.tr(context),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  image: user.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 30,
                        color: Theme.of(context).dividerColor,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phoneNumber ??
                        TranslationKeys.noPhoneNumber.tr(context),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return _buildSectionContainer(
            title: TranslationKeys.shippingAddress.tr(context),
            child: Text(
              TranslationKeys.loginToManageAddresses.tr(context),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          );
        }

        final addresses = authProvider.currentUser?.addresses ?? [];

        return _buildSectionContainer(
          title: TranslationKeys.shippingAddress.tr(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (addresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    TranslationKeys.noSavedAddresses.tr(context),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),

              if (addresses.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final isSelected = _selectedAddresses.any(
                      (a) => a.id == address.id,
                    );

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedAddresses.removeWhere(
                                (a) => a.id == address.id,
                              );
                            } else {
                              _selectedAddresses.add(address);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color ??
                                        Colors.white
                                  : Theme.of(context).dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color
                                    : Theme.of(context).dividerColor,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          address.label?.toLowerCase() == 'home'
                                              ? Icons.home
                                              : Icons.business,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          address.label ??
                                              TranslationKeys.addressFallback
                                                  .tr(context),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${address.street}, ${address.city}, ${address.state} ${address.zipCode}, ${address.country}',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddressFormDialog(),
                  ).then((_) {
                    if (!context.mounted) return;
                    final updatedAddresses =
                        context.read<AuthProvider>().currentUser?.addresses ??
                        [];
                    if (updatedAddresses.isNotEmpty &&
                        !_selectedAddresses.any(
                          (a) => a.id == updatedAddresses.last.id,
                        )) {
                      setState(() {
                        _selectedAddresses.add(updatedAddresses.last);
                      });
                    }
                  });
                },
                icon: const Icon(Icons.add),
                label: Text(TranslationKeys.addNewAddress.tr(context)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Consumer<CompanyProvider>(
      builder: (context, companyProvider, child) {
        final methods =
            companyProvider.companySettings?.paymentMethods ?? [PaymentMethodType.cod];

        if (methods.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildSectionContainer(
          title: TranslationKeys.paymentMethod.tr(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: methods.map((method) {
              final isSelected = _selectedPaymentMethod == method;
              final methodData = ModelPaymenttype.availableMethods.firstWhere(
                (m) => m.id == method.name,
                orElse: () => ModelPaymenttype.availableMethods.first,
              );
              final String title = methodData.title.get(context);
              final String iconPath = methodData.icon;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = method;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).scaffoldBackgroundColor
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.white
                              : Theme.of(context).dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            iconPath,
                            width: 28,
                            height: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
