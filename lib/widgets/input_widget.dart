import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/form_data_manager.dart';

class InputWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final FormDataManager? formDataManager;

  const InputWidget({
    super.key,
    required this.widgetData,
    this.formDataManager,
  });

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.widgetData['key']?.toString() ?? '';
    final label = widget.widgetData['label']?.toString() ?? '';
    final placeholder = widget.widgetData['placeholder']?.toString() ?? '';
    final required = widget.widgetData['required'] == true;
    final inputType = widget.widgetData['input_type']?.toString() ?? 'text';
    final icon = widget.widgetData['icon']?.toString();
    final maxLength = widget.widgetData['max_length'] as int?;
    final marginBottom = (widget.widgetData['margin_bottom'] as num?)?.toDouble() ?? 16.0;
    final visibility = widget.widgetData['visibility']?.toString() ?? 'visible';
    final id = widget.widgetData['id']?.toString();
    final value = widget.widgetData['value']?.toString() ?? '';
    final lines = widget.widgetData['lines'] as int? ?? 1;
    final showBorder = widget.widgetData['border'] ?? true;
    final hintColor = _parseColor(widget.widgetData['hint_color']?.toString());
    final textColor = _parseColor(widget.widgetData['text_color']?.toString());
    final fontSize = (widget.widgetData['fontSize'] as num?)?.toDouble() ?? 16.0;

    // Initialize controller and FormDataManager with value on first build
    if (!_initialized && value.isNotEmpty) {
      _controller.text = value;
      if (key.isNotEmpty && widget.formDataManager != null) {
        widget.formDataManager!.setValue(key, value);
      }
      _initialized = true;
    }

    // Handle visibility - but still set value in FormDataManager even when hidden
    if (visibility == 'hidden') {
      // Ensure the value is in FormDataManager even though widget is hidden
      if (!_initialized && value.isNotEmpty && key.isNotEmpty && widget.formDataManager != null) {
        widget.formDataManager!.setValue(key, value);
        _initialized = true;
      }
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom),
      child: TextFormField(
        controller: _controller,
        obscureText: inputType == 'password',
        maxLength: maxLength,
        maxLines: inputType == 'multiline' ? lines : 1,
        minLines: inputType == 'multiline' ? lines : 1,
        keyboardType: _getKeyboardType(inputType),
        inputFormatters: _getInputFormatters(inputType, maxLength),
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontSize: fontSize,
        ),
        decoration: InputDecoration(
          labelText: label.isNotEmpty ? label : null,
          hintText: placeholder,
          hintStyle: hintColor != null ? TextStyle(color: hintColor) : null,
          prefixIcon: icon != null ? Icon(_getIcon(icon)) : null,
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          counterText: maxLength != null ? '' : null,
          border: showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                )
              : InputBorder.none,
          enabledBorder: showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                )
              : InputBorder.none,
          focusedBorder: showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                )
              : InputBorder.none,
          errorBorder: showBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                )
              : InputBorder.none,
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
        onChanged: (value) {
          final key = widget.widgetData['key']?.toString();
          if (key != null && key.isNotEmpty && widget.formDataManager != null) {
            widget.formDataManager!.setValue(key, value);
          }
        },
      ),
    );
  }

  TextInputType _getKeyboardType(String inputType) {
    switch (inputType) {
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      case 'number':
        return TextInputType.number;
      case 'url':
        return TextInputType.url;
      case 'multiline':
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters(String inputType, int? maxLength) {
    List<TextInputFormatter> formatters = [];
    
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }
    
    if (inputType == 'number' || inputType == 'phone') {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    
    return formatters;
  }

  IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'phone':
        return Icons.phone;
      case 'lock':
        return Icons.lock;
      case 'email':
        return Icons.email;
      case 'person':
        return Icons.person;
      case 'search':
        return Icons.search;
      case 'link':
        return Icons.link;
      default:
        return Icons.text_fields;
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    
    try {
      var hex = colorString.replaceAll('#', '').trim().toLowerCase();
      
      if (hex.length == 8) {
        final alpha = hex.substring(6, 8);
        final rgb = hex.substring(0, 6);
        hex = alpha + rgb;
        return Color(int.parse(hex, radix: 16));
      } else if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
