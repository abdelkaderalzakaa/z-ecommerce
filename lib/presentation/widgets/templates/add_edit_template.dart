import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

/// A model representing a single section/card in the Add/Edit form.
/// Each section contains a title, optional icon, and a list of form field widgets.
class FormSection {
  /// Section title (e.g., 'Store Information', 'Owner Account')
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Optional leading icon for the section header
  final IconData? icon;

  /// The form fields/widgets inside this section
  final List<Widget> fields;

  const FormSection({
    required this.title,
    this.subtitle,
    this.icon,
    required this.fields,
  });
}

/// A reusable, responsive, unified Add/Edit Template widget for Flutter applications.
/// Capable of handling form layouts for any entity (Stores, Products, Orders, Users, etc.).
///
/// Features:
/// - Top header bar with back button, title, and optional action buttons
/// - Scrollable body with grouped form sections (cards)
/// - Sticky bottom action bar with primary submit and optional secondary buttons
/// - Loading/submitting overlay state
/// - Responsive layout (single column on mobile, multi-column on desktop)
class AddEditTemplate extends StatelessWidget {
  /// Header page title (e.g., 'إنشاء متجر جديد', 'تعديل المنتج')
  final String title;

  /// Optional subtitle below the title
  final String? subtitle;

  /// Whether this is an edit (true) or create (false) operation
  final bool isEditMode;

  /// Back action callback (defaults to Navigator.pop(context))
  final VoidCallback? onBack;

  /// The Form key used for validation
  final GlobalKey<FormState>? formKey;

  /// Grouped form sections displayed as cards
  final List<FormSection> sections;

  /// Primary submit button label (e.g., 'إنشاء المتجر', 'حفظ التعديلات')
  final String submitLabel;

  /// Primary submit callback
  final VoidCallback? onSubmit;

  /// Whether the form is currently submitting
  final bool isSubmitting;

  /// Optional secondary action button (e.g., 'Save as Draft')
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  /// Optional cancel button label (defaults to showing back navigation)
  final String? cancelLabel;
  final VoidCallback? onCancel;

  /// Optional extra action widgets in the top action bar
  final List<Widget>? extraHeaderActions;

  /// Optional extra widgets at the bottom, before the submit button
  final Widget? bottomExtra;

  /// Icon for the submit button
  final IconData? submitIcon;

  const AddEditTemplate({
    super.key,
    required this.title,
    this.subtitle,
    this.isEditMode = false,
    this.onBack,
    this.formKey,
    required this.sections,
    required this.submitLabel,
    this.onSubmit,
    this.isSubmitting = false,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.cancelLabel,
    this.onCancel,
    this.extraHeaderActions,
    this.bottomExtra,
    this.submitIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Pinned Top Header Bar
            _buildHeaderBar(context, theme),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.12)),

            // 2. Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 32.0 : 16.0,
                  vertical: 20.0,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form Sections as Cards
                      for (int i = 0; i < sections.length; i++) ...[
                        _buildSectionCard(context, theme, sections[i], isWide),
                        if (i < sections.length - 1) const SizedBox(height: 20),
                      ],

                      // Optional bottom extra widget
                      if (bottomExtra != null) ...[
                        const SizedBox(height: 20),
                        bottomExtra!,
                      ],

                      // Bottom spacing for the fixed footer
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Pinned Bottom Action Bar
            _buildBottomActionBar(context, theme),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // 1. TOP HEADER BAR
  // ───────────────────────────────────────────────
  Widget _buildHeaderBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      isEditMode
                          ? Icons.edit_note_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 22,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Extra Header Actions
          if (extraHeaderActions != null) ...extraHeaderActions!,
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // 2. SECTION CARD
  // ───────────────────────────────────────────────
  Widget _buildSectionCard(
    BuildContext context,
    ThemeData theme,
    FormSection section,
    bool isWide,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 24.0 : 16.0,
              vertical: 14.0,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                if (section.icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      section.icon,
                      size: 18,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (section.subtitle != null &&
                          section.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          section.subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: theme.dividerColor.withOpacity(0.08)),

          // Section Fields
          Padding(
            padding: EdgeInsets.all(isWide ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildFieldsWithSpacing(section.fields),
            ),
          ),
        ],
      ),
    );
  }

  /// Adds consistent vertical spacing between form fields.
  List<Widget> _buildFieldsWithSpacing(List<Widget> fields) {
    final result = <Widget>[];
    for (int i = 0; i < fields.length; i++) {
      result.add(fields[i]);
      if (i < fields.length - 1) {
        result.add(const SizedBox(height: 16));
      }
    }
    return result;
  }

  // ───────────────────────────────────────────────
  // 3. BOTTOM ACTION BAR
  // ───────────────────────────────────────────────
  Widget _buildBottomActionBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel / Back Button
          if (onCancel != null || cancelLabel != null)
            OutlinedButton(
              onPressed: isSubmitting
                  ? null
                  : (onCancel ?? () => Navigator.of(context).pop()),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
              ),
              child: Text(
                cancelLabel ?? 'إلغاء',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const Spacer(),

          // Secondary Action Button
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : onSecondaryAction,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(secondaryActionLabel!),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Primary Submit Button
          ButtonApp(
            onPressed: isSubmitting ? null : onSubmit,
            isLoading:isSubmitting ,
            icon:  submitIcon ??
                        (isEditMode
                            ? Icons.check_circle_outline_rounded
                            : Icons.add_circle_outline_rounded),
                   
            label:  
              submitLabel, 
            ),  
        ],
      ),
    );
  }
}
