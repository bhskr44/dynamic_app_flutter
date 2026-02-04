// filepath: lib/screens/dynamic_screen.dart
import 'dart:convert';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shimmer/shimmer.dart';
import '../core/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/form_data_manager.dart';
import '../widgets/dynamic_widget_builder.dart';
import '../utils/actions_handler.dart';

class DynamicScreen extends StatefulWidget {
  final String apiUrl;
  const DynamicScreen({super.key, required this.apiUrl});

  @override
  State<DynamicScreen> createState() => _DynamicScreenState();
}

class _DynamicScreenState extends State<DynamicScreen> {

    // Helper: Parse color from hex string
    Color _parseColor(String colorString) {
      try {
        var hex = colorString.replaceAll('#', '').trim().toLowerCase();
        if (hex.length == 8) {
          // RRGGBBAA -> AARRGGBB
          final alpha = hex.substring(6, 8);
          final rgb = hex.substring(0, 6);
          hex = alpha + rgb;
          return Color(int.parse(hex, radix: 16));
        } else if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 3) {
          final r = hex[0] + hex[0];
          final g = hex[1] + hex[1];
          final b = hex[2] + hex[2];
          return Color(int.parse('FF$r$g$b', radix: 16));
        }
      } catch (e) {
        debugPrint('Error parsing color $colorString: $e');
      }
      return const Color(0xFF6366F1);
    }

    // Helper: Get text color based on background brightness
    Color _getTextColor(List<Color> backgroundColors) {
      double totalBrightness = 0;
      for (var color in backgroundColors) {
        final brightness = (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
        totalBrightness += brightness;
      }
      final averageBrightness = totalBrightness / backgroundColors.length;
      return averageBrightness > 128 ? const Color(0xFF1E293B) : Colors.white;
    }

    // Helper: Parse gradient from background map
    Gradient _parseGradient(Map<String, dynamic> background) {
      final type = background['type']?.toString() ?? 'gradient';
      final colors = (background['colors'] as List<dynamic>?)
              ?.map((c) => _parseColor(c.toString()))
              .toList() ??
          [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      final angle = (background['angle'] as num?)?.toDouble() ?? 0.0;
      // Convert angle to alignment
      final radians = angle * 3.14159 / 180;
      final begin = Alignment(-1 * (1 - radians / 3.14159), -1.0);
      final end = Alignment(1 * (1 - radians / 3.14159), 1.0);
      return LinearGradient(
        colors: colors,
        begin: angle == 90 ? Alignment.topCenter : (angle == 0 ? Alignment.centerLeft : begin),
        end: angle == 90 ? Alignment.bottomCenter : (angle == 0 ? Alignment.centerRight : end),
      );
    }
  Map<String, dynamic>? screenData;
  bool loading = true;
  String? error;
  late int _shimmerLayout;
  final FormDataManager _formDataManager = FormDataManager();

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
        final uri = Uri.parse(widget.apiUrl);
        if (uri.queryParameters.isNotEmpty) {
          uri.queryParameters.forEach((key, value) {
            _formDataManager.setValue(key, value);
          });
        }
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

      debugPrint('Loaded screenData: ' + data.toString());
      if (data['widgets'] != null) {
        debugPrint('widgets: ' + data['widgets'].toString());
      }
      // Extra debug: check for empty or invalid widgets
      if (data['widgets'] == null || (data['widgets'] is List && (data['widgets'] as List).isEmpty)) {
        debugPrint('WARNING: API returned no widgets or widgets is empty.');
      }
      setState(() {
        screenData = data;
        loading = false;
      });
    } catch (e, stack) {
      debugPrint('ERROR loading screen: $e\n$stack');
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

    // Show error if widgets is empty or missing, but NOT for splash_screen
    if (screenData != null && (screenData?['widgets'] == null || (widgets is List && widgets.isEmpty)) && ((screenData?['screen_type'] == null) || (screenData?['screen_type'] != 'splash_screen'))) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Color(0xFFF59E42),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Content',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This screen has no widgets to display.\nPlease check your API response or try again later.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                // Show the API URL being accessed
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.link, size: 18, color: Color(0xFF6366F1)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SelectableText(
                          widget.apiUrl,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w500,
                          ),
                          enableInteractiveSelection: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Go Home button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => DynamicScreen(apiUrl: 'https://96845f5b1425.ngrok-free.app/api/app-screens/home-screen'),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_rounded, size: 18),
                      label: const Text('Go Home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    if (Navigator.canPop(context))
                      const SizedBox(width: 12),
                    // Retry button
                    ElevatedButton.icon(
                      onPressed: _loadScreen,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64748B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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

    // SPLASH SCREEN LOGIC
    final isSplash = (screenData?['screen_type'] ?? '') == 'splash_screen';
    if (isSplash && widgets.isEmpty) {
      // Parse splash fields
      final background = screenData?['background'] as Map<String, dynamic>?;
      final appLogo = screenData?['app_logo']?.toString() ?? '';
      final appTitle = screenData?['app_title']?.toString() ?? '';
      final appName = screenData?['app_name']?.toString() ?? '';
      final appDescription = screenData?['app_description']?.toString() ?? '';
      final appVersion = screenData?['app_version']?.toString() ?? '';
      final animationData = screenData?['animation'] as Map<String, dynamic>?;
      final navigation = screenData?['navigation'] as Map<String, dynamic>?;
      final saveCache = screenData?['save_cache'];

      // Clear cache if save_cache is false
      if (saveCache == false) {
        // Clear API response cache
        ApiService.clearCache();
        // Clear image cache for splash logo
        if (appLogo.isNotEmpty) {
          CachedNetworkImage.evictFromCache(appLogo);
        }
        debugPrint('Cache cleared due to save_cache: false');
      }

      // Parse gradient colors
      List<Color> gradientColors = [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      if (background != null && background['colors'] != null) {
        gradientColors = (background['colors'] as List<dynamic>)
            .map((c) => _parseColor(c.toString()))
            .toList();
      }
      final textColor = _getTextColor(gradientColors);

      // Animation
      AnimationController? _animationController;
      Animation<double>? _fadeAnimation;
      final animationType = animationData?['type']?.toString() ?? 'fade_in';
      final duration = (animationData?['duration'] as num?)?.toInt() ?? 2000;

      // Navigation
      if (navigation != null && navigation['type'] == 'auto') {
        final delay = (navigation['delay'] as num?)?.toInt() ?? 1000;
        final target = navigation['target']?.toString();
        if (target != null && target.isNotEmpty) {
          Future.delayed(Duration(milliseconds: delay + duration), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => DynamicScreen(apiUrl: target),
                ),
              );
            }
          });
        }
      }

      Widget content = Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(flex: 2),
          // Logo and main content
          Column(
            children: [
              if (appLogo.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: textColor.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      appLogo,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.apps_rounded,
                            size: 60,
                            color: textColor.withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (appLogo.isNotEmpty) const SizedBox(height: 40),
              if (appTitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    appTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                  ),
                ),
              if (appTitle.isEmpty && appName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              if (appDescription.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: Text(
                    appDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.65),
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              // (No API URL shown on splash screen)
            ],
          ),
          const Spacer(flex: 2),
          // Version at bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                if (appVersion.isNotEmpty)
                  Text(
                    appVersion,
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withOpacity(0.4),
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );

      return Scaffold(
        body: Container(
          decoration: background != null
              ? BoxDecoration(gradient: _parseGradient(background))
              : const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
          child: Center(child: content),
        ),
      );
    }

    // Add extra top padding to the first search_bar if AppBar is present
    final hasAppBar = Navigator.canPop(context);
    List<Widget> widgetList = widgets.asMap().entries.map((entry) {
      final i = entry.key;
      final map = entry.value as Map<String, dynamic>;
      final isFirst = i == 0;
      final isSearchBar = (map['type'] ?? '') == 'search_bar';
      if (isFirst && isSearchBar && hasAppBar) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: DynamicWidgetBuilder.build(
            map,
            context,
            onNavigateRefresh: _loadScreen,
            screenData: screenData,
            formDataManager: _formDataManager,
          ),
        );
      }
      return DynamicWidgetBuilder.build(
        map,
        context,
        onNavigateRefresh: _loadScreen,
        screenData: screenData,
        formDataManager: _formDataManager,
      );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: hasAppBar
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
      body: SafeArea(
        child: widgets.isEmpty
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
                    children: widgetList,
                  ),
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