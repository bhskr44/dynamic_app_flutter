import 'package:flutter/material.dart';

class VariantSelectorWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final Function(Map<String, dynamic>)? onVariantSelected;

  const VariantSelectorWidget({
    super.key,
    required this.widgetData,
    this.onVariantSelected,
  });

  @override
  State<VariantSelectorWidget> createState() => _VariantSelectorWidgetState();
}

class _VariantSelectorWidgetState extends State<VariantSelectorWidget> {
  final Map<String, dynamic> _selectedVariants = {};

  @override
  Widget build(BuildContext context) {
    final variants = (widget.widgetData['variants'] as List<dynamic>?) ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: variants.map((variant) {
          final variantMap = variant as Map<String, dynamic>;
          return _buildVariantGroup(variantMap);
        }).toList(),
      ),
    );
  }

  Widget _buildVariantGroup(Map<String, dynamic> variant) {
    final key = variant['key']?.toString() ?? '';
    final label = variant['label']?.toString() ?? '';
    final type = variant['type']?.toString() ?? 'chip';
    final options = (variant['options'] as List<dynamic>?) ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          if (type == 'chip')
            _buildChipSelector(key, options)
          else if (type == 'dropdown')
            _buildDropdownSelector(key, label, options)
          else if (type == 'color')
            _buildColorSelector(key, options),
        ],
      ),
    );
  }

  Widget _buildChipSelector(String key, List<dynamic> options) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final optionMap = option as Map<String, dynamic>;
        final value = optionMap['value']?.toString() ?? '';
        final label = optionMap['label']?.toString() ?? value;
        final available = optionMap['available'] ?? true;
        final isSelected = _selectedVariants[key] == value;

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: available
              ? (selected) {
                  setState(() {
                    if (selected) {
                      _selectedVariants[key] = value;
                    } else {
                      _selectedVariants.remove(key);
                    }
                  });
                  widget.onVariantSelected?.call(_selectedVariants);
                }
              : null,
          selectedColor: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFFF8FAFC),
          disabledColor: const Color(0xFFE2E8F0),
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : available
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownSelector(String key, String label, List<dynamic> options) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVariants[key]?.toString(),
          hint: Text('Select $label'),
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: BorderRadius.circular(12),
          items: options.map((option) {
            final optionMap = option as Map<String, dynamic>;
            final value = optionMap['value']?.toString() ?? '';
            final label = optionMap['label']?.toString() ?? value;
            final available = optionMap['available'] ?? true;

            return DropdownMenuItem<String>(
              value: value,
              enabled: available,
              child: Text(
                label,
                style: TextStyle(
                  color: available ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedVariants[key] = value;
              });
              widget.onVariantSelected?.call(_selectedVariants);
            }
          },
        ),
      ),
    );
  }

  Widget _buildColorSelector(String key, List<dynamic> options) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final optionMap = option as Map<String, dynamic>;
        final value = optionMap['value']?.toString() ?? '';
        final colorHex = optionMap['color']?.toString() ?? '#000000';
        final label = optionMap['label']?.toString();
        final available = optionMap['available'] ?? true;
        final isSelected = _selectedVariants[key] == value;

        final color = _parseColor(colorHex);

        return GestureDetector(
          onTap: available
              ? () {
                  setState(() {
                    _selectedVariants[key] = value;
                  });
                  widget.onVariantSelected?.call(_selectedVariants);
                }
              : null,
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: !available
                    ? const Icon(Icons.close, color: Colors.white, size: 20)
                    : isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
              ),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: available ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
