import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

/// A text-input field with inline autocomplete suggestions.
///
/// The user types freely; matching items appear in an overlay below.
/// Pressing **Enter** selects the top match (or the highlighted one)
/// and moves focus to [nextFocus]. Arrow keys navigate suggestions.
class TypeaheadField<T> extends StatefulWidget {
  const TypeaheadField({
    required this.items,
    required this.onChanged,
    super.key,
    this.value,
    this.label,
    this.placeholder,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.nextFocus,
    this.fillColor,
    this.overlayColor,
    this.textColor,
    this.borderColor,
    this.errorColor,
  });

  final List<({T value, String label})> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? label;
  final String? placeholder;
  final String? Function(T?)? validator;
  final bool enabled;
  final Color? fillColor;
  final Color? overlayColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? errorColor;

  /// Optional external focus node. If null, an internal one is created.
  final FocusNode? focusNode;

  /// Focus node to jump to after a selection is confirmed via Enter.
  final FocusNode? nextFocus;

  @override
  State<TypeaheadField<T>> createState() => _TypeaheadFieldState<T>();
}

class _TypeaheadFieldState<T> extends State<TypeaheadField<T>> {
  final _controller = TextEditingController();
  final _layerLink = LayerLink();
  final _fieldKey = GlobalKey();
  FocusNode? _internalFocusNode;
  OverlayEntry? _overlay;
  int _highlightIndex = 0;
  List<({T value, String label})> _filtered = [];
  bool _ignoreNextChange = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _syncText();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant TypeaheadField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _syncText();
    }
    // Only refilter if items actually changed (content comparison).
    if (!_listEquals(widget.items, oldWidget.items)) {
      _filter(_controller.text);
    }
  }

  bool _listEquals(
    List<({T value, String label})> a,
    List<({T value, String label})> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].value != b[i].value || a[i].label != b[i].label) return false;
    }
    return true;
  }

  void _syncText() {
    final match = widget.items.where((i) => i.value == widget.value);
    final text = match.isNotEmpty ? match.first.label : '';
    if (_controller.text != text) {
      _ignoreNextChange = true;
      _controller.text = text;
    }
  }

  bool get _isOptional => widget.validator == null;

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Optional field with no items — skip overlay entirely.
      if (_isOptional && widget.items.isEmpty) return;
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
      _filter(_controller.text);
      _showOverlay();
    } else {
      _resolveAndClose();
    }
  }

  void _filter(String query) {
    if (query.isEmpty) {
      _filtered = List.of(widget.items);
    } else {
      final q = query.toLowerCase();
      _filtered = widget.items
          .where((item) => item.label.toLowerCase().contains(q))
          .toList();
    }
    _highlightIndex = 0;
  }

  void _showOverlay() {
    _removeOverlay();
    if (_filtered.isEmpty) return;

    _overlay = OverlayEntry(builder: (_) => _buildOverlay());
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay?.dispose();
    _overlay = null;
  }

  void _updateOverlay() {
    _overlay?.markNeedsBuild();
  }

  void _resolveAndClose() {
    _removeOverlay();
    final text = _controller.text.trim().toLowerCase();
    final match = widget.items.where(
      (i) => i.label.toLowerCase() == text,
    );
    if (match.isNotEmpty) {
      _select(match.first, moveFocus: false);
    } else if (text.isEmpty) {
      widget.onChanged(null);
    }
  }

  void _select(({T value, String label}) item, {bool moveFocus = true}) {
    _ignoreNextChange = true;
    _controller.text = item.label;
    _controller.selection = TextSelection.collapsed(
      offset: item.label.length,
    );
    widget.onChanged(item.value);
    _removeOverlay();
    if (moveFocus && widget.nextFocus != null) {
      widget.nextFocus!.requestFocus();
    }
  }

  void _onTextChanged(String text) {
    if (_ignoreNextChange) {
      _ignoreNextChange = false;
      return;
    }
    setState(() {
      _filter(text);
    });
    if (_focusNode.hasFocus) {
      if (_filtered.isNotEmpty) {
        _showOverlay();
        _updateOverlay();
      } else {
        _removeOverlay();
      }
    }
    widget.onChanged(null);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_filtered.isNotEmpty) {
        setState(() {
          _highlightIndex =
              (_highlightIndex + 1).clamp(0, _filtered.length - 1);
        });
        _updateOverlay();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_filtered.isNotEmpty) {
        setState(() {
          _highlightIndex =
              (_highlightIndex - 1).clamp(0, _filtered.length - 1);
        });
        _updateOverlay();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.tab) {
      // Optional + empty → skip to next field without selecting anything.
      if (_isOptional && _controller.text.trim().isEmpty) {
        _removeOverlay();
        if (widget.nextFocus != null) {
          widget.nextFocus!.requestFocus();
        }
        return KeyEventResult.handled;
      }
      if (_filtered.isNotEmpty) {
        _select(_filtered[_highlightIndex]);
        return KeyEventResult.handled;
      }
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _removeOverlay();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  double _fieldWidth() {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _internalFocusNode?.dispose();
    _controller.dispose();
    super.dispose();
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
                color: widget.textColor ?? theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        CompositedTransformTarget(
          link: _layerLink,
          child: Focus(
            onKeyEvent: _onKey,
            child: TextField(
              key: _fieldKey,
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              onChanged: _onTextChanged,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.textColor ?? AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  color: (widget.textColor ?? AppColors.textPrimary)
                      .withValues(alpha: 0.5),
                ),
                isDense: true,
                filled: widget.fillColor != null,
                fillColor: widget.fillColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: widget.borderColor ?? AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: widget.borderColor ?? AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: widget.borderColor ?? AppColors.primary,
                      width: 1.5),
                ),
                suffixIcon: widget.value != null
                    ? GestureDetector(
                        onTap: () {
                          _controller.clear();
                          widget.onChanged(null);
                          _focusNode.requestFocus();
                        },
                        child: Icon(Icons.close,
                            size: 16,
                            color: widget.textColor?.withValues(alpha: 0.7)),
                      )
                    : Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: widget.textColor?.withValues(alpha: 0.7) ??
                            AppColors.textMuted,
                      ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 4),
          child: Text(
            errorText ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: errorText != null
                  ? (widget.errorColor ?? theme.colorScheme.error)
                  : Colors.transparent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlay() {
    final width = _fieldWidth();

    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: const Offset(0, 44),
      child: Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(10),
          color: widget.overlayColor ?? Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 220,
              maxWidth: width,
              minWidth: width,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                final isHighlighted = index == _highlightIndex;
                return InkWell(
                  onTap: () => _select(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    color: isHighlighted
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : null,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isHighlighted
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isHighlighted
                            ? (widget.textColor ?? AppColors.primary)
                            : (widget.textColor ?? AppColors.textPrimary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
