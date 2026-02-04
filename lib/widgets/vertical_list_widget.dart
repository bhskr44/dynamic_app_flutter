import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/actions_handler.dart';
import '../core/form_data_manager.dart';
import 'dynamic_widget_builder.dart';

typedef RefreshCallback = Future<void> Function();

class VerticalListWidget extends StatelessWidget {
  final Map<String, dynamic> widgetData;
  final RefreshCallback? onNavigateRefresh;
  final FormDataManager? formDataManager;

  const VerticalListWidget({
    super.key,
    required this.widgetData,
    this.onNavigateRefresh,
    this.formDataManager,
  });

  @override
  Widget build(BuildContext context) {
    final items = (widgetData['items'] as List<dynamic>?) ?? [];
    final style = widgetData['style'] as Map<String, dynamic>?;
    final title = (widgetData['title'] ?? '').toString().trim();
    final displayTitle = widgetData['display_title'] ?? true;

    // ---------------- EMPTY STATE ----------------
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty && displayTitle) _buildTitle(title),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.inbox_rounded,
                      size: 32, color: Color(0xFF94A3B8)),
                  SizedBox(width: 12),
                  Text(
                    'No data available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ---------------- DYNAMIC WIDGETS ----------------
    final firstItem = items.first;
    final firstType = firstItem is Map<String, dynamic>
      ? firstItem['type']?.toString().toLowerCase()
      : null;

    // Only treat as dynamic when the item type is a custom widget (not a legacy
    // "category" item). Categories should use the legacy list renderer.
    final hasDynamicType = firstItem is Map<String, dynamic> &&
      firstItem.containsKey('type') &&
      firstType != 'category';

    if (hasDynamicType) {
      // Special handling: if the first item is a post create section (button + horizontal_layout),
      // combine them into a FbCreatePostCardWidget for Facebook-style post creation UI.
      bool isCreatePostSection = false;
      if (items.length >= 2 &&
          items[0] is Map<String, dynamic> && items[1] is Map<String, dynamic> &&
          (items[0]['type'] == 'button' || items[0]['type'] == 'fb_create_post_card') &&
          items[1]['type'] == 'horizontal_layout') {
        isCreatePostSection = true;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty && displayTitle)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: _buildTitle(title),
            ),
          if (isCreatePostSection)
            DynamicWidgetBuilder.build({
              'type': 'fb_create_post_card',
              'user_avatar': items[0]['user_avatar'] ?? '',
              'placeholder': items[0]['button_text'] ?? "What's on your mind?",
              'placeholder_color': items[0]['text_color'] ?? '#65676B',
              'action': items[0]['action'],
              'quick_actions': (items[1]['items'] as List<dynamic>?)?.map((qa) => {
                'icon': qa['button_icon'] ?? 'photo',
                'text': qa['button_text'] ?? '',
                'color': qa['button_color'] ?? '#45bd62',
                'action': qa['action'],
              }).toList() ?? [],
              'background_color': items[0]['button_color'] ?? '#fff',
              'border_radius': items[0]['border_radius'] ?? 8,
              'margin_bottom': items[0]['margin_bottom'] ?? 16,
              'elevation': 2,
              'padding': 12,
            }, context, onNavigateRefresh: onNavigateRefresh),
          ...items.skip(isCreatePostSection ? 2 : 0).map((item) {
            if (item is Map<String, dynamic>) {
              final type = item['type']?.toString().toLowerCase();
              if (type == 'vendors') {
                // Render vendor card
                final img = item['image']?.toString() ?? '';
                final itemTitle = (item['title'] ?? '').toString();
                final description = (item['description'] ?? '').toString();
                final action = item['action'] as Map<String, dynamic>?;
                return InkWell(
                  onTap: action != null
                      ? () => ActionsHandler.handle(
                            action,
                            context,
                            parentRefresh: onNavigateRefresh,
                          )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    constraints: const BoxConstraints(minHeight: 90),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildImageContainer(img, 90, false),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (itemTitle.isNotEmpty)
                                  Text(
                                    itemTitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (action != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: IconButton(
                              icon: const Icon(Icons.call, color: Colors.green, size: 20),
                              onPressed: () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              } else {
                return DynamicWidgetBuilder.build(
                  item,
                  context,
                  onNavigateRefresh: onNavigateRefresh,
                  formDataManager: formDataManager,
                );
              }
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      );
    }

    // ---------------- LEGACY LIST ----------------
    return _buildLegacyList(context, items, title, displayTitle, style);
  }

  // ==========================================================
  // LEGACY LIST BUILDER
  // ==========================================================

  Widget _buildLegacyList(
    BuildContext context,
    List<dynamic> items,
    String title,
    bool displayTitle,
    Map<String, dynamic>? style,
  ) {
    final shape = style?['shape']?.toString() ?? 'rectangle';
    final styleHeight = (style?['height'] as num?)?.toDouble();
    final itemHeight = styleHeight ?? 120.0;
    final isCircle = shape.toLowerCase() == 'circle';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty && displayTitle) _buildTitle(title),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (ctx, i) {
              final map = items[i] as Map<String, dynamic>;
              final img = map['image']?.toString() ?? '';
              final itemTitle = (map['title'] ?? '').toString();
              final subtitle = (map['subtitle'] ?? '').toString();
              final description = (map['description'] ?? '').toString();
              final action = map['action'] as Map<String, dynamic>?;

              final isCallPhone = action != null && (action['type'] == 'call_phone');
              return InkWell(
                onTap: action != null
                    ? () => ActionsHandler.handle(
                          action,
                          context,
                          parentRefresh: onNavigateRefresh,
                        )
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: BoxConstraints(minHeight: itemHeight),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildImageContainer(img, itemHeight, isCircle),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (itemTitle.isNotEmpty)
                                Text(
                                  itemTitle,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (subtitle.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (action != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: isCallPhone
                              ? IconButton(
                                  icon: const Icon(Icons.call, color: Colors.green, size: 22),
                                  onPressed: () => ActionsHandler.handle(action, context, parentRefresh: onNavigateRefresh),
                                )
                              : const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Color(0xFF94A3B8)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // UI HELPERS
  // ==========================================================

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(String img, double size, bool isCircle) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
      child: isCircle
          ? Center(
              child: ClipOval(
                child: _buildImage(img, size - 32),
              ),
            )
          : ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: _buildImage(img, size),
            ),
    );
  }

  // ==========================================================
  // IMAGE HANDLING
  // ==========================================================

  Widget _buildImage(String url, double size) {
    if (url.isEmpty) return _placeholder(size);

    final cleanUrl = _sanitizeUrl(url);
    if (cleanUrl.isEmpty) return _placeholder(size);

    if (cleanUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        cleanUrl,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => _placeholder(size),
      );
    }

    // Restore previous implementation using Image.network
    return Image.network(
      cleanUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _placeholder(size),
      errorBuilder: (_, error, __) {
        debugPrint('Image load error: $cleanUrl');
        return _errorIcon(size);
      },
    );
  }

  Widget _placeholder(double size) => Container(
        width: size,
        height: size,
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.image_rounded,
            size: 32, color: Color(0xFF94A3B8)),
      );

  Widget _errorIcon(double size) => Container(
        width: size,
        height: size,
        color: const Color(0xFFFEF2F2),
        child: const Icon(Icons.broken_image_rounded,
            size: 32, color: Color(0xFFEF4444)),
      );

  String _sanitizeUrl(String url) {
    var cleaned = url.trim();
    if (cleaned.startsWith('url(')) {
      cleaned = cleaned.substring(4, cleaned.length - 1);
    }
    return cleaned.replaceAll('"', '').replaceAll("'", '').trim();
  }
}
