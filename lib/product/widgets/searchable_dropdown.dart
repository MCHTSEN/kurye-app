import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A searchable dropdown widget backed by [ShadSelect.withSearch].
///
/// Replaces [DropdownButtonFormField] across the app with a filterable,
/// type-to-search dropdown experience.
class SearchableDropdown<T> extends StatefulWidget {
  const SearchableDropdown({
    required this.items,
    required this.onChanged,
    super.key,
    this.value,
    this.label,
    this.placeholder,
    this.validator,
    this.enabled = true,
    this.searchPlaceholder,
    this.minWidth,
    this.maxWidth,
    this.selectedTextStyle,
    this.placeholderTextStyle,
  });

  /// Items available for selection. Each entry is a (value, label) pair.
  final List<({T value, String label})> items;

  /// Called when the user selects an option.
  final ValueChanged<T?> onChanged;

  /// Currently selected value.
  final T? value;

  /// Label displayed above the dropdown (like InputDecoration.labelText).
  final String? label;

  /// Placeholder shown when nothing is selected.
  final String? placeholder;

  /// Validator for form integration. Return non-null string for error.
  final String? Function(T?)? validator;

  /// Whether the dropdown is interactive.
  final bool enabled;

  /// Placeholder text inside the search input.
  final String? searchPlaceholder;

  /// Minimum width passed to the underlying select trigger.
  final double? minWidth;

  /// Maximum width passed to the underlying select trigger.
  final double? maxWidth;

  /// Style used for the selected value when the dropdown is closed.
  final TextStyle? selectedTextStyle;

  /// Style used for the placeholder text.
  final TextStyle? placeholderTextStyle;

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  String _search = '';

  List<({T value, String label})> get _filtered {
    if (_search.isEmpty) return widget.items;
    final q = _search.toLowerCase();
    return widget.items
        .where((item) => item.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = widget.validator?.call(widget.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ShadSelect<T>.withSearch(
          enabled: widget.enabled,
          minWidth: widget.minWidth ?? double.infinity,
          maxWidth: widget.maxWidth,
          maxHeight: 300,
          initialValue: widget.value,
          placeholder: Text(
            widget.placeholder ?? 'Seç...',
            style: widget.placeholderTextStyle,
          ),
          onSearchChanged: (value) {
            setState(() => _search = value);
          },
          searchPlaceholder: Text(
            widget.searchPlaceholder ?? 'Ara...',
          ),
          onChanged: (v) {
            widget.onChanged(v);
          },
          selectedOptionBuilder: (context, value) {
            final match = widget.items.where((i) => i.value == value);
            if (match.isEmpty) {
              return Text(
                widget.placeholder ?? 'Seç...',
                style: widget.placeholderTextStyle,
              );
            }
            return Text(match.first.label, style: widget.selectedTextStyle);
          },
          options: [
            if (_filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Sonuç bulunamadı',
                  textAlign: TextAlign.center,
                ),
              ),
            for (final item in _filtered)
              ShadOption<T>(
                value: item.value,
                child: Text(item.label),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            errorText ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: errorText != null
                  ? theme.colorScheme.error
                  : Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
