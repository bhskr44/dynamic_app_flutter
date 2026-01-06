import 'package:flutter/material.dart';
import '../utils/actions_handler.dart';

typedef RefreshCallback = Future<void> Function();

class FormWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final RefreshCallback? onNavigateRefresh;

  const FormWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final fields = (widget.widgetData['fields'] as List<dynamic>?) ?? [];
    final submitAction = widget.widgetData['submit_action'] as Map<String, dynamic>?;
    final submitLabel = widget.widgetData['submit_label']?.toString() ?? 'Submit';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...fields.map((field) => _buildField(field as Map<String, dynamic>)),
                const SizedBox(height: 24),
                _buildSubmitButton(submitLabel, submitAction),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    final type = field['type']?.toString() ?? 'text';
    final key = field['key']?.toString() ?? '';
    final label = field['label']?.toString() ?? '';
    final placeholder = field['placeholder']?.toString() ?? '';
    final required = field['required'] == true;
    final obscureText = field['obscure'] == true;

    switch (type) {
      case 'text':
      case 'email':
      case 'password':
      case 'number':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            obscureText: obscureText || type == 'password',
            keyboardType: type == 'email'
                ? TextInputType.emailAddress
                : type == 'number'
                    ? TextInputType.number
                    : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
            ),
            validator: required
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    if (type == 'email' && !value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  }
                : null,
            onSaved: (value) => _formData[key] = value,
          ),
        );

      case 'dropdown':
        final options = (field['options'] as List<dynamic>?) ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: options.map((opt) {
              final optMap = opt as Map<String, dynamic>;
              return DropdownMenuItem(
                value: optMap['value']?.toString(),
                child: Text(optMap['label']?.toString() ?? ''),
              );
            }).toList(),
            validator: required ? (value) => value == null ? '$label is required' : null : null,
            onChanged: (value) => _formData[key] = value,
          ),
        );

      case 'checkbox':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CheckboxListTile(
            title: Text(label),
            value: _formData[key] ?? false,
            onChanged: (value) => setState(() => _formData[key] = value),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF6366F1),
          ),
        );

      case 'textarea':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            maxLines: 4,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
            ),
            validator: required ? (value) => value == null || value.isEmpty ? '$label is required' : null : null,
            onSaved: (value) => _formData[key] = value,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSubmitButton(String label, Map<String, dynamic>? action) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : () => _handleSubmit(action),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSubmit(Map<String, dynamic>? action) async {
    if (_formKey.currentState?.validate() != true) return;
    
    _formKey.currentState?.save();

    if (action == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Add form data to the action
      final actionWithData = Map<String, dynamic>.from(action);
      actionWithData['body'] = _formData;

      await ActionsHandler.handle(actionWithData, context, parentRefresh: widget.onNavigateRefresh);
      
      // Clear form on success if specified
      if (widget.widgetData['clear_on_success'] == true) {
        _formKey.currentState?.reset();
        setState(() => _formData.clear());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
