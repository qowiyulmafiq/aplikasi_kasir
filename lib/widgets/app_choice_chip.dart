import 'package:flutter/material.dart';

/// One selected-state pattern for category/sort chips.
///
/// Used by the filter sheet, POS, inventory, and Cashier Mode so a "selected"
/// chip always looks the same: primaryContainer fill, primary border, bold
/// onPrimaryContainer label, and a tinted optional icon.
class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final ValueChanged<bool> onSelected;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 16,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outlineVariant,
        width: selected ? 1.5 : 1,
      ),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
      ),
    );
  }
}
