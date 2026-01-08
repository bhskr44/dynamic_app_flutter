// filepath: lib/screens/dynamic_screen.dart
import 'dart:convert';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shimmer/shimmer.dart';
import '../core/api_service.dart';
import '../widgets/dynamic_widget_builder.dart';
import '../utils/actions_handler.dart';

class DynamicScreen extends StatefulWidget {
  final String apiUrl;
  const DynamicScreen({super.key, required this.apiUrl});

  @override
  State<DynamicScreen> createState() => _DynamicScreenState();
}

class _DynamicScreenState extends State<DynamicScreen> {
  Map<String, dynamic>? screenData;
  bool loading = true;
  String? error;
  late int _shimmerLayout;

  @override
  void initState() {
    super.initState();
    _shimmerLayout = Random().nextInt(3); // Random layout: 0, 1, or 2
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      Map<String, dynamic> data;
      if (widget.apiUrl.startsWith('http')) {
        data = await ApiService.fetchJson(widget.apiUrl);
      } else {
        // treat as asset path (e.g., "sampleapi.json")
        final raw = await rootBundle.loadString(widget.apiUrl);
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          data = {'widgets': decoded};
        }
      }

      setState(() {
        screenData = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: _buildShimmerLayout(),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        // appBar: Navigator.canPop(context)
        //     ? AppBar(
        //         backgroundColor: Colors.transparent,
        //         elevation: 0,
        //         leading: IconButton(
        //           icon: const Icon(Icons.arrow_back_ios_new_rounded),
        //           onPressed: () => Navigator.pop(context),
        //         ),
        //       )
        //     : null,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Go Back button
                    if (Navigator.canPop(context))
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Go Back'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(
                            color: Color(0xFF6366F1),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    if (Navigator.canPop(context))
                      const SizedBox(width: 12),
                    // Try Again button
                    Container(
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
                        onPressed: _loadScreen,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final widgets = (screenData?['widgets'] as List<dynamic>?) ?? [];
    final displayTitle = screenData?['display_title'] ?? true;
    final screenTitle = screenData?['screen_title']?.toString();
    final bottomNavData = screenData?['bottom_navigation'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: Navigator.canPop(context)
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
                color: const Color(0xFF1E293B),
              ),
              title: screenTitle != null && screenTitle.isNotEmpty
                  ? Text(
                      screenTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    )
                  : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  color: const Color(0xFFE2E8F0),
                  height: 1,
                ),
              ),
            )
          : null,
      body: widgets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inbox_rounded,
                        size: 64,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Data Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'There is no content to display at the moment.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadScreen,
              color: const Color(0xFF6366F1),
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widgets.map((w) {
                    final map = (w as Map<String, dynamic>);
                    return DynamicWidgetBuilder.build(map, context, onNavigateRefresh: _loadScreen, screenData: screenData);
                  }).toList(),
                ),
              ),
            ),
      bottomNavigationBar: bottomNavData != null ? _buildBottomNavigation(bottomNavData) : null,
    );
  }

  Widget? _buildBottomNavigation(Map<String, dynamic> navData) {
    final items = navData['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final itemMap = item as Map<String, dynamic>;
              final icon = itemMap['icon']?.toString() ?? 'circle';
              final label = itemMap['label']?.toString() ?? '';
              final action = itemMap['action'] as Map<String, dynamic>?;
              final isActive = itemMap['active'] == true;
              
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (action != null) {
                      ActionsHandler.handle(action, context);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getIconData(icon),
                          size: 24,
                          color: isActive ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;
      case 'card_giftcard':
        return Icons.card_giftcard_rounded;
      case 'account_circle':
        return Icons.account_circle_rounded;
      case 'people':
        return Icons.people_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'search':
        return Icons.search_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'notifications':
        return Icons.notifications_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  Widget _buildShimmerLayout() {
    switch (_shimmerLayout) {
      case 0:
        return _buildShimmerLayout1();
      case 1:
        return _buildShimmerLayout2();
      case 2:
        return _buildShimmerLayout3();
      default:
        return _buildShimmerLayout1();
    }
  }

  // Layout 1: Classic horizontal + vertical
  Widget _buildShimmerLayout1() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          _shimmerBox(height: 56, width: double.infinity, radius: 16),
          const SizedBox(height: 24),
          _shimmerBox(height: 24, width: 200, radius: 4),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      _shimmerBox(height: 100, width: 100, radius: 16),
                      const SizedBox(height: 8),
                      _shimmerBox(height: 12, width: 80, radius: 4),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _shimmerBox(height: 100, width: double.infinity, radius: 16),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Layout 2: Grid layout
  Widget _buildShimmerLayout2() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          _shimmerBox(height: 56, width: double.infinity, radius: 16),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 20, width: double.infinity, radius: 4)),
              const SizedBox(width: 12),
              _shimmerBox(height: 20, width: 80, radius: 4),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _shimmerBox(height: double.infinity, width: double.infinity, radius: 16),
                    ),
                    const SizedBox(height: 8),
                    _shimmerBox(height: 14, width: double.infinity, radius: 4),
                    const SizedBox(height: 4),
                    _shimmerBox(height: 12, width: 100, radius: 4),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Layout 3: Card-based layout
  Widget _buildShimmerLayout3() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          Row(
            children: [
              _shimmerBox(height: 40, width: 40, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(height: 16, width: 150, radius: 4),
                    const SizedBox(height: 4),
                    _shimmerBox(height: 12, width: 100, radius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _shimmerBox(height: 200, width: double.infinity, radius: 20),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 16, width: double.infinity, radius: 4)),
              const SizedBox(width: 8),
              Expanded(child: _shimmerBox(height: 16, width: double.infinity, radius: 4)),
              const SizedBox(width: 8),
              Expanded(child: _shimmerBox(height: 16, width: double.infinity, radius: 4)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      _shimmerBox(height: 80, width: 80, radius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerBox(height: 16, width: double.infinity, radius: 4),
                            const SizedBox(height: 8),
                            _shimmerBox(height: 12, width: 200, radius: 4),
                            const SizedBox(height: 8),
                            _shimmerBox(height: 14, width: 100, radius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, required double width, required double radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}