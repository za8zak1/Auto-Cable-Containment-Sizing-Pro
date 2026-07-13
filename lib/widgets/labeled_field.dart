import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Text field with a small floating label above it and an optional trailing
/// unit + "?" help icon, matching the reference screenshots.
class LabeledTextField extends StatelessWidget {
  final String label;
  final String? suffix;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? helpText;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.helpText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (suffix != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(suffix!,
                          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                    ),
                  _HelpButton(text: helpText ?? label),
                ],
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}

/// Read-only computed value display styled like the input fields but
/// non-editable (e.g. "Calculated Ib").
class LabeledReadout extends StatelessWidget {
  final String label;
  final String value;
  final String? helpText;

  const LabeledReadout({super.key, required this.label, required this.value, this.helpText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              _HelpButton(text: helpText ?? label),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dropdown field styled consistently with [LabeledTextField].
class LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: items.entries
                  .map((e) => DropdownMenuItem<T>(
                        value: e.key,
                        child: Text(e.value,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ))
                  .toList(),
              onChanged: (v) {
                // DropdownButton's callback is always typed T? at the
                // Flutter API level, even when T itself is nullable (e.g.
                // LabeledDropdown<String?> for "Any material"). Cast back to
                // T rather than early-returning on null, otherwise picking
                // a deliberately null-valued item (like "Any material")
                // would be silently ignored.
                onChanged(v as T);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HelpButton extends StatelessWidget {
  final String text;
  const _HelpButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  'Field help text goes here - describe assumptions, units and '
                  'the standard reference used for this input.',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.question_mark_rounded, size: 14, color: AppColors.primaryTeal),
      ),
    );
  }
}
