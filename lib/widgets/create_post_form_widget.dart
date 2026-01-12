import 'package:flutter/material.dart';
import '../utils/actions_handler.dart';
import '../core/form_data_manager.dart';

class CreatePostFormWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;
  final FormDataManager? formDataManager;

  const CreatePostFormWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
    this.formDataManager,
  });

  @override
  State<CreatePostFormWidget> createState() => _CreatePostFormWidgetState();
}

class _CreatePostFormWidgetState extends State<CreatePostFormWidget> {
  final TextEditingController _contentController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.widgetData['placeholder']?.toString() ?? "What's on your mind?";
    final backgroundColor = _parseColor(widget.widgetData['background_color']?.toString()) ?? Colors.white;
    final borderRadius = (widget.widgetData['border_radius'] as num?)?.toDouble() ?? 8.0;
    final padding = (widget.widgetData['padding'] as num?)?.toDouble() ?? 16.0;
    final minHeight = (widget.widgetData['min_height'] as num?)?.toDouble() ?? 150.0;
    final submitAction = widget.widgetData['submit_action'] as Map<String, dynamic>?;
    final userAvatar = widget.widgetData['user_avatar']?.toString();

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info section
            if (userAvatar != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: userAvatar.isNotEmpty 
                        ? NetworkImage(userAvatar) 
                        : null,
                    child: userAvatar.isEmpty 
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.widgetData['user_name']?.toString() ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Text input
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 5,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (value) {
                // Store in form data manager if field name is provided
                final fieldName = widget.widgetData['field_name']?.toString() ?? 'content';
                widget.formDataManager?.setValue(fieldName, value);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isPosting || _contentController.text.trim().isEmpty
                      ? null
                      : () => _handleSubmit(submitAction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(widget.widgetData['submit_text']?.toString() ?? 'Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(Map<String, dynamic>? action) async {
    if (action == null) return;
    
    setState(() => _isPosting = true);
    
    try {
      // Store content in form data manager
      final fieldName = widget.widgetData['field_name']?.toString() ?? 'content';
      widget.formDataManager?.setValue(fieldName, _contentController.text);
      
      await ActionsHandler.handle(
        action,
        context,
        parentRefresh: widget.onNavigateRefresh,
        formDataManager: widget.formDataManager,
      );
      
      // Clear and pop on success
      _contentController.clear();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Error handling is done in ActionsHandler
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
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
