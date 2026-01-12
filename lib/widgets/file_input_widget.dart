import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/form_data_manager.dart';

class FileInputWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  final FormDataManager? formDataManager;

  const FileInputWidget({
    super.key,
    required this.widgetData,
    this.formDataManager,
  });

  @override
  State<FileInputWidget> createState() => _FileInputWidgetState();
}

class _FileInputWidgetState extends State<FileInputWidget> {
  final List<XFile> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final key = widget.widgetData['key']?.toString() ?? '';
    final placeholder = widget.widgetData['placeholder']?.toString() ?? 'Select files';
    final accept = widget.widgetData['accept']?.toString() ?? 'image/*';
    final multiple = widget.widgetData['multiple'] ?? false;
    final maxFiles = widget.widgetData['max_files'] as int? ?? 10;
    final buttonText = widget.widgetData['button_text']?.toString() ?? 'Choose Files';
    final buttonIcon = widget.widgetData['button_icon']?.toString();
    final buttonColor = _parseColor(widget.widgetData['button_color']?.toString()) ?? const Color(0xFFE7F3E9);
    final buttonTextColor = _parseColor(widget.widgetData['button_text_color']?.toString()) ?? const Color(0xFF45BD62);
    final showPreview = widget.widgetData['preview'] ?? true;
    final previewStyle = widget.widgetData['preview_style']?.toString() ?? 'list';

    final isImage = accept.contains('image');
    final isVideo = accept.contains('video');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // File selection buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickFromGallery(isImage, isVideo, multiple, maxFiles),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonTextColor,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(_getIconData(buttonIcon ?? 'photo_library')),
                label: Text(buttonText),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _pickFromCamera(isImage, isVideo),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ),
        
        // Preview
        if (showPreview && _selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          if (previewStyle == 'grid')
            _buildGridPreview()
          else
            _buildListPreview(),
        ],
        
        // File count
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '${_selectedFiles.length} ${_selectedFiles.length == 1 ? 'file' : 'files'} selected',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGridPreview() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedFiles.length,
      itemBuilder: (context, index) {
        final file = _selectedFiles[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: kIsWeb
                  ? Image.network(file.path, fit: BoxFit.cover)
                  : Image.file(File(file.path), fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeFile(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildListPreview() {
    return Column(
      children: _selectedFiles.asMap().entries.map((entry) {
        final index = entry.key;
        final file = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: kIsWeb
                      ? Image.network(file.path, fit: BoxFit.cover)
                      : Image.file(File(file.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file.name,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _removeFile(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickFromGallery(bool isImage, bool isVideo, bool multiple, int maxFiles) async {
    try {
      if (multiple) {
        final List<XFile> files = await _picker.pickMultiImage();
        if (files.isNotEmpty) {
          setState(() {
            _selectedFiles.addAll(files.take(maxFiles - _selectedFiles.length));
            _updateFormData();
          });
        }
      } else {
        final XFile? file = isVideo
            ? await _picker.pickVideo(source: ImageSource.gallery)
            : await _picker.pickImage(source: ImageSource.gallery);
        
        if (file != null) {
          setState(() {
            _selectedFiles.clear();
            _selectedFiles.add(file);
            _updateFormData();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting files: $e')),
        );
      }
    }
  }

  Future<void> _pickFromCamera(bool isImage, bool isVideo) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: ImageSource.camera)
          : await _picker.pickImage(source: ImageSource.camera);
      
      if (file != null) {
        setState(() {
          if (!widget.widgetData['multiple']) {
            _selectedFiles.clear();
          }
          _selectedFiles.add(file);
          _updateFormData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _updateFormData();
    });
  }

  void _updateFormData() {
    final key = widget.widgetData['key']?.toString();
    if (key != null && key.isNotEmpty && widget.formDataManager != null) {
      // Store file paths as comma-separated string
      final paths = _selectedFiles.map((f) => f.path).join(',');
      widget.formDataManager!.setValue(key, paths);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'photo_library':
        return Icons.photo_library;
      case 'add_photo_alternate':
        return Icons.add_photo_alternate;
      case 'videocam':
        return Icons.videocam;
      case 'attach_file':
        return Icons.attach_file;
      default:
        return Icons.upload_file;
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
