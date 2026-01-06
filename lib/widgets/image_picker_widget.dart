import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImagePickerWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final Function(String)? onImageSelected;

  const ImagePickerWidget({
    super.key,
    required this.widgetData,
    this.onImageSelected,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final label = widget.widgetData['label']?.toString() ?? 'Select Image';
    final allowCamera = widget.widgetData['allow_camera'] ?? true;
    final allowGallery = widget.widgetData['allow_gallery'] ?? true;
    final maxWidth = (widget.widgetData['max_width'] as num?)?.toDouble();
    final maxHeight = (widget.widgetData['max_height'] as num?)?.toDouble();
    final quality = (widget.widgetData['quality'] as num?)?.toInt() ?? 85;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_imagePath != null)
            Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: kIsWeb
                    ? Image.network(_imagePath!, fit: BoxFit.cover)
                    : Image.file(File(_imagePath!), fit: BoxFit.cover),
              ),
            ),
          Row(
            children: [
              if (allowCamera)
                Expanded(
                  child: _buildPickerButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => _pickImage(
                      ImageSource.camera,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      quality: quality,
                    ),
                  ),
                ),
              if (allowCamera && allowGallery) const SizedBox(width: 12),
              if (allowGallery)
                Expanded(
                  child: _buildPickerButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickImage(
                      ImageSource.gallery,
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      quality: quality,
                    ),
                  ),
                ),
            ],
          ),
          if (_imagePath != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => _imagePath = null),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              label: const Text(
                'Remove Image',
                style: TextStyle(color: Color(0xFFEF4444)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(
    ImageSource source, {
    double? maxWidth,
    double? maxHeight,
    int quality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: quality,
      );

      if (image != null) {
        setState(() => _imagePath = image.path);
        widget.onImageSelected?.call(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }
}
