import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/widgets/common/footers/footer_buisness.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/invoice_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/business_provider.dart';
import '../../../../data/models/common/address_model.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/core/responsive/responsive_layout.dart';
import '../../../widgets/common/headers/header_details.dart';
import '../../../widgets/common/footers/footer_section.dart';
import '../../../widgets/cart/order_summary.dart';
import '../../../widgets/cart/cart_item.dart';
import '../../../widgets/common/headers/widgets/top_title.dart';
import '../../../widgets/profile/tabs/widgets/address_form_dialog.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/customer/cart/confirm_order_page.dart';
import 'package:z_ecommerce/presentation/pages/auth/login_page.dart';

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
        final addresses = authProvider.currentCustomer?.addresses ?? [];
        if (addresses.isNotEmpty) {
          setState(() {
            _selectedAddresses.add(addresses.first);
          });
        }
      }

      final businessProvider = context.read<BusinessProvider>();
      final methods =
          businessProvider.selectedBusiness?.paymentMethods ??
          [PaymentMethodType.cashOnDelivery];
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

    final businessId = context.read<BusinessProvider>().selectedBusiness?.id;

    if (cartProvider.items(businessId).isEmpty) {
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

    final subtotal = cartProvider.subTotal(businessId);
    final discount = subtotal * 0.20;
    final shipping = subtotal > 0 ? 15.0 : 0.0;

    List<String> generatedids = [];

    for (var address in _selectedAddresses) {
      invoiceProvider.generateInvoice(
        storeId: businessId,
        items: cartProvider.items(businessId),
        discount: discount,
        tax: 0,
        shippingCost: shipping,
        shippingAddress: address,
      );
      generatedids.add(invoiceProvider.invoices.last.id);
    }

    cartProvider.clearCart(businessId);

    changeScreen(context, ConfirmOrderPage(ids: generatedids));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final hPad = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: HeaderDetails(
        title: TranslationKeys.checkoutTitle.tr(context),
        fallbackRoute: 'cart',
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
            FooterBuisness(
              idBuisness:
                  context.read<BusinessProvider>().selectedBusiness?.id ?? '',
            ),
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
                ButtonApp(
                  onPressed: () {
                    changeScreen(context, const LoginPage());
                  },
                  label: TranslationKeys.login.tr(context),
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
                  image: DecorationImage(
                    image: NetworkImage(user.avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: null,
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
                    user.phoneNumber,
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

        final addresses = authProvider.currentCustomer?.addresses ?? [];

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

                    return InkWell(
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
                                        address.title.toLowerCase() ==
                                                    'home' ||
                                                address.title.toLowerCase() ==
                                                    'المنزل'
                                            ? Icons.home
                                            : Icons.business,
                                        size: 16,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        address.title.isNotEmpty
                                            ? address.title
                                            : TranslationKeys.addressFallback
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
                                    address.getFormattedAddress(
                                      langCode: Localizations.localeOf(
                                        context,
                                      ).languageCode,
                                    ),
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
                        context
                            .read<AuthProvider>()
                            .currentCustomer
                            ?.addresses ??
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
    return Consumer<BusinessProvider>(
      builder: (context, businessProvider, child) {
        final methods =
            businessProvider.selectedBusiness?.paymentMethods ??
            [PaymentMethodType.cashOnDelivery];

        if (methods.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildSectionContainer(
          title: TranslationKeys.paymentMethod.tr(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: methods.map((method) {
              final isSelected = _selectedPaymentMethod == method;
              final methodData = PaymentMethodModel.availableMethods.firstWhere(
                (m) => m.id == method.name,
                orElse: () => PaymentMethodModel.availableMethods.first,
              );
              final String title = methodData.title.get(context);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
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
                        Icon(
                          method.name == 'cod'
                              ? Icons.money
                              : method.name == 'creditCard'
                              ? Icons.credit_card
                              : method.name == 'paypal'
                              ? Icons.paypal
                              : Icons.account_balance_wallet,
                          size: 28,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
