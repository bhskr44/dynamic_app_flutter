import 'package:flutter/material.dart';
import '../utils/actions_handler.dart';

class FbCreatePostCardWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;

  const FbCreatePostCardWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseColor(widgetData['background_color']?.toString()) ?? Colors.white;
    final borderRadius = (widgetData['border_radius'] as num?)?.toDouble() ?? 8.0;
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 8.0;
    final elevation = (widgetData['elevation'] as num?)?.toDouble() ?? 2.0;
    final padding = (widgetData['padding'] as num?)?.toDouble() ?? 12.0;
    final userAvatar = widgetData['user_avatar']?.toString() ?? '';
    final placeholder = widgetData['placeholder']?.toString() ?? "What's on your mind?";
    final placeholderColor = _parseColor(widgetData['placeholder_color']?.toString()) ?? const Color(0xFF65676B);
    final action = widgetData['action'] as Map<String, dynamic>?;
    final quickActions = widgetData['quick_actions'] as List<dynamic>? ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Card(
        color: backgroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              // Top section with avatar and input
              Row(
                children: [
                  // User Avatar
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
                  // Input placeholder
                  Expanded(
                    child: GestureDetector(
                      onTap: action != null
                          ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          placeholder,
                          style: TextStyle(
                            color: placeholderColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Quick actions
              if (quickActions.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: quickActions.map((quickAction) {
                    final iconName = quickAction['icon']?.toString() ?? 'photo';
                    final text = quickAction['text']?.toString() ?? 'Photo';
                    final color = _parseColor(quickAction['color']?.toString()) ?? Colors.green;
                    final quickActionData = quickAction['action'] as Map<String, dynamic>?;
                    
                    return Expanded(
                      child: InkWell(
                        onTap: quickActionData != null
                            ? () => ActionsHandler.handle(quickActionData, context, parentRefresh: onNavigateRefresh)
                            : action != null
                                ? () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh)
                                : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIconData(iconName),
                                color: color,
                                size: 24,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                text,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'photo_library':
      case 'photo':
        return Icons.photo_library;
      case 'videocam':
      case 'video':
        return Icons.videocam;
      case 'location_on':
      case 'location':
        return Icons.location_on;
      case 'emoji_emotions':
      case 'emoji':
        return Icons.emoji_emotions;
      case 'tag':
        return Icons.local_offer;
      default:
        return Icons.photo_library;
    }
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    
    try {
      var hex = colorString.replaceAll('#', '').trim().toLowerCase();
      
      if (hex.length == 8) {
        // Handle RRGGBBAA format - convert to AARRGGBB for Flutter
        final alpha = hex.substring(6, 8);
        final rgb = hex.substring(0, 6);
        hex = alpha + rgb;
        return Color(int.parse(hex, radix: 16));
      } else if (hex.length == 6) {
        // RRGGBB format - add FF for full opacity
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
}
