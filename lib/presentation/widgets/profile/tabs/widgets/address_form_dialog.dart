import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import '../../../../../../data/models/common/address_model.dart';
import '../../../../../../data/providers/customer_provider.dart';
import '../../../../../../data/providers/auth_provider.dart';
import '../../../../global/translate/app_localizations.dart';
import '../../../../global/translate/translation_keys.dart';
import '../../../../global/translate/localized_string.dart';

class AddressFormDialog extends StatefulWidget {
  final AddressModel? initialAddress;

  const AddressFormDialog({super.key, this.initialAddress});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _regionController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialAddress?.title ?? '');
    _streetController = TextEditingController(text: widget.initialAddress?.street ?? '');
    _cityController = TextEditingController(text: widget.initialAddress?.city.ar ?? '');
    _regionController = TextEditingController(text: widget.initialAddress?.region.ar ?? '');
    _postalCodeController = TextEditingController(text: widget.initialAddress?.postalCode ?? '');
    _countryController = TextEditingController(text: widget.initialAddress?.country.ar ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final titleStr = _titleController.text.trim().isEmpty ? 'العنوان' : _titleController.text.trim();
      final streetStr = _streetController.text.trim();
      final cityStr = _cityController.text.trim();
      final regionStr = _regionController.text.trim();
      final postalStr = _postalCodeController.text.trim();
      final countryStr = _countryController.text.trim();

      final newAddress = AddressModel(
        id: widget.initialAddress?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: titleStr,
        street: streetStr,
        building: widget.initialAddress?.building ?? '',
        city: LocalizedString(ar: cityStr, en: cityStr),
        region: LocalizedString(ar: regionStr, en: regionStr),
        country: LocalizedString(ar: countryStr, en: countryStr),
        postalCode: postalStr,
      );

      final customer = context.read<AuthProvider>().currentCustomer;
      if (customer != null) {
        final currentAddresses = List<AddressModel>.from(customer.addresses);
        if (widget.initialAddress == null) {
          currentAddresses.add(newAddress);
        } else {
          final idx = currentAddresses.indexWhere((a) => a.id == newAddress.id);
          if (idx >= 0) {
            currentAddresses[idx] = newAddress;
          } else {
            currentAddresses.add(newAddress);
          }
        }
        context.read<CustomerProvider>().updateAddresses(customer.id, currentAddresses);
      }
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAddress != null;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? TranslationKeys.editAddress.tr(context) : TranslationKeys.addNewAddress.tr(context),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _titleController,
                  label: TranslationKeys.addressLabelOptional.tr(context),
                  hintText: TranslationKeys.egHomeWork.tr(context),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _streetController,
                  label: TranslationKeys.streetAddress.tr(context),
                  hintText: TranslationKeys.enterStreetAddress.tr(context),
                  validator: (val) => val == null || val.isEmpty ? TranslationKeys.requiredValidation.tr(context) : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _cityController,
                        label: TranslationKeys.city.tr(context),
                        hintText: TranslationKeys.city.tr(context),
                        validator: (val) => val == null || val.isEmpty ? TranslationKeys.requiredValidation.tr(context) : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthTextField(
                        controller: _regionController,
                        label: TranslationKeys.state.tr(context),
                        hintText: TranslationKeys.state.tr(context),
                        validator: (val) => val == null || val.isEmpty ? TranslationKeys.requiredValidation.tr(context) : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _postalCodeController,
                        label: TranslationKeys.zipCode.tr(context),
                        hintText: TranslationKeys.zipCode.tr(context),
                        validator: (val) => val == null || val.isEmpty ? TranslationKeys.requiredValidation.tr(context) : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AuthTextField(
                        controller: _countryController,
                        label: TranslationKeys.country.tr(context),
                        hintText: TranslationKeys.country.tr(context),
                        validator: (val) => val == null || val.isEmpty ? TranslationKeys.requiredValidation.tr(context) : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    child: Text(TranslationKeys.saveAddress.tr(context)),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
