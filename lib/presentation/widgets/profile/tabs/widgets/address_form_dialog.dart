import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/widgets/auth/auth_text_field.dart';
import '../../../../../../data/models/address_model.dart';
import '../../../../../../data/providers/auth_provider.dart';
import '../../../../global/translate/app_localizations.dart';
import '../../../../global/translate/translation_keys.dart';

class AddressFormDialog extends StatefulWidget {
  final AddressModel? initialAddress;

  const AddressFormDialog({super.key, this.initialAddress});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.initialAddress?.label ?? '');
    _streetController = TextEditingController(text: widget.initialAddress?.street ?? '');
    _cityController = TextEditingController(text: widget.initialAddress?.city ?? '');
    _stateController = TextEditingController(text: widget.initialAddress?.state ?? '');
    _zipController = TextEditingController(text: widget.initialAddress?.zipCode ?? '');
    _countryController = TextEditingController(text: widget.initialAddress?.country ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = AddressModel(
        id: widget.initialAddress?.id,
        label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
        country: _countryController.text.trim(),
      );

      final authProvider = context.read<AuthProvider>();
      if (widget.initialAddress == null) {
        authProvider.addAddress(newAddress);
      } else {
        authProvider.updateAddress(newAddress);
      }
      
      context.pop();
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
                        onTap: () => context.pop(),
                        child: Icon(Icons.close, color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AuthTextField(
                  controller: _labelController,
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
                        controller: _stateController,
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
                        controller: _zipController,
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
