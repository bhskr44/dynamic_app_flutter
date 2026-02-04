import 'package:flutter/material.dart';
import '../utils/actions_handler.dart';
import 'video_player_widget.dart';

class FbPostCardWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final Future<void> Function()? onNavigateRefresh;

  const FbPostCardWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
  });

  @override
  Widget build(BuildContext context) {
      debugPrint('FbPostCardWidget build: widgetData = ' + widgetData.toString());
    final backgroundColor = _parseColor(widgetData['background_color']?.toString()) ?? Colors.white;
    final borderRadius = (widgetData['border_radius'] as num?)?.toDouble() ?? 8.0;
    final marginBottom = (widgetData['margin_bottom'] as num?)?.toDouble() ?? 8.0;
    final elevation = (widgetData['elevation'] as num?)?.toDouble() ?? 2.0;
    final padding = (widgetData['padding'] as num?)?.toDouble() ?? 12.0;
    
    final header = widgetData['header'] as Map<String, dynamic>?;
    final content = widgetData['content']?.toString() ?? '';
    final contentColor = _parseColor(widgetData['content_color']?.toString()) ?? Colors.black;
    final contentSize = (widgetData['content_size'] as num?)?.toDouble() ?? 15.0;
    final image = widgetData['image']?.toString();
    final videoUrl = widgetData['video_url']?.toString();
    final mediaHeight = (widgetData['media_height'] as num?)?.toDouble() ?? 300.0;
    final stats = widgetData['stats'] as Map<String, dynamic>?;
    final actions = widgetData['actions'] as List<dynamic>? ?? [];
    final onTap = widgetData['on_tap'] as Map<String, dynamic>?;

    return GestureDetector(
      onTap: onTap != null ? () => ActionsHandler.handle(onTap, context, parentRefresh: onNavigateRefresh) : null,
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom),
        child: Card(
          color: backgroundColor,
          elevation: elevation,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              if (header != null) _buildHeader(header, padding),
              
              // Content
              if (content.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: contentSize,
                      height: 1.4,
                    ),
                  ),
                ),
              
              // Media (Image or Video)
              if (image != null && image.isNotEmpty)
                Image.network(
                  image,
                  width: double.infinity,
                  height: mediaHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: mediaHeight,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                ),
              
              if (videoUrl != null && videoUrl.isNotEmpty)
                VideoPlayerWidget(
                  widgetData: {
                    'url': videoUrl,
                    'autoplay': true,
                    'loop': true,
                    'aspect_ratio': 16 / 9,
                  },
                ),
              
              // Stats
              if (stats != null) _buildStats(stats, padding),
              
              const Divider(height: 1),
              
              // Actions
              if (actions.isNotEmpty) _buildActions(actions, padding, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> header, double padding) {
    final userAvatar = header['user_avatar']?.toString() ?? '';
    final userName = header['user_name']?.toString() ?? 'User';
    final timestamp = header['timestamp']?.toString() ?? '';
    final postTypeIcon = header['post_type_icon']?.toString();

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: userAvatar.isNotEmpty ? NetworkImage(userAvatar) : null,
            child: userAvatar.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF050505),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      timestamp,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (postTypeIcon != null) ...[
                      const SizedBox(width: 4),
                      Icon(
                        _getPostTypeIcon(postTypeIcon),
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Map<String, dynamic> stats, double padding) {
    final likesCount = stats['likes_count'] ?? 0;
    final commentsCount = stats['comments_count'] ?? 0;
    final sharesCount = stats['shares_count'] ?? 0;

    if (likesCount == 0 && commentsCount == 0 && sharesCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      child: Row(
        children: [
          if (likesCount > 0) ...[
            Icon(Icons.favorite, size: 18, color: Colors.red[400]),
            const SizedBox(width: 4),
            Text(
              '$likesCount',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
          const Spacer(),
          if (commentsCount > 0)
            Text(
              '$commentsCount ${commentsCount == 1 ? 'comment' : 'comments'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          if (commentsCount > 0 && sharesCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('•', style: TextStyle(color: Colors.grey[700])),
            ),
          if (sharesCount > 0)
            Text(
              '$sharesCount ${sharesCount == 1 ? 'share' : 'shares'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(List<dynamic> actions, double padding, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding / 2, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((actionData) {
          if (actionData is! Map<String, dynamic>) return const SizedBox.shrink();
          
          final type = actionData['type']?.toString() ?? '';
          final icon = actionData['icon']?.toString() ?? '';
          final text = actionData['text']?.toString() ?? '';
          final color = _parseColor(actionData['color']?.toString()) ?? Colors.grey[600]!;
          final isLiked = actionData['is_liked'] ?? false;

          IconData iconData;
          Color iconColor = color;
          
          if (type == 'like_button') {
            iconData = isLiked ? Icons.favorite : Icons.favorite_border;
            iconColor = isLiked ? Colors.red : color;
          } else if (type == 'comment_button') {
            iconData = Icons.comment;
          } else if (type == 'share_button') {
            iconData = Icons.share;
          } else {
            iconData = _getIconData(icon);
          }

          return Expanded(
            child: InkWell(
              onTap: () => _handleAction(actionData, context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconData, size: 20, color: iconColor),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleAction(Map<String, dynamic> actionData, BuildContext context) {
    final clickAction = actionData['click_action']?.toString();
    
    if (clickAction == 'api_call') {
      ActionsHandler.handle(actionData, context, parentRefresh: onNavigateRefresh);
    } else if (clickAction == 'navigate') {
      final api = actionData['api']?.toString();
      if (api != null) {
        ActionsHandler.handle({'type': 'navigate', 'api': api}, context, parentRefresh: onNavigateRefresh);
      }
    } else if (clickAction == 'share') {
      ActionsHandler.handle(actionData, context, parentRefresh: onNavigateRefresh);
    }
  }

  IconData _getPostTypeIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'photo':
        return Icons.photo_library;
      case 'videocam':
      case 'video':
        return Icons.videocam;
      case 'location_on':
        return Icons.location_on;
      default:
        return Icons.public;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'favorite':
      case 'favorite_border':
        return Icons.favorite_border;
      case 'comment':
        return Icons.comment;
      case 'share':
        return Icons.share;
      default:
        return Icons.thumb_up_outlined;
    }
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return Colors.grey;
    
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
      return Colors.grey;
    }
    return Colors.grey;
  }
}
