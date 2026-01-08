import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import '../core/api_service.dart';
import 'dynamic_screen.dart';

class SplashScreen extends StatefulWidget {
  final String apiUrl;
  
  const SplashScreen({super.key, required this.apiUrl});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? splashData;
  bool loading = true;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadSplashData();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadSplashData() async {
    try {
      Map<String, dynamic> data;
      
      if (widget.apiUrl.startsWith('http')) {
        data = await ApiService.fetchJson(widget.apiUrl);
      } else {
        final raw = await rootBundle.loadString(widget.apiUrl);
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          data = {};
        }
      }

      setState(() {
        splashData = data;
        loading = false;
      });

      // Check if we should clear cache
      final saveCache = data['save_cache'];
      if (saveCache == false) {
        // Clear API response cache
        await ApiService.clearCache();
        // Clear image cache
        await CachedNetworkImage.evictFromCache(widget.apiUrl);
        debugPrint('Cache cleared due to save_cache: false');
      }

      // Setup animation
      final animationData = data['animation'] as Map<String, dynamic>?;
      final animationType = animationData?['type']?.toString() ?? 'fade_in';
      final duration = (animationData?['duration'] as num?)?.toInt() ?? 2000;

      if (animationType == 'fade_in') {
        _animationController = AnimationController(
          duration: Duration(milliseconds: duration),
          vsync: this,
        );
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
        );
        _animationController!.forward();
      }

      // Handle navigation
      final navigation = data['navigation'] as Map<String, dynamic>?;
      if (navigation != null && navigation['type'] == 'auto') {
        final delay = (navigation['delay'] as num?)?.toInt() ?? 1000;
        final target = navigation['target']?.toString();
        
        if (target != null && target.isNotEmpty) {
          await Future.delayed(Duration(milliseconds: delay + duration));
          
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => DynamicScreen(apiUrl: target),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        loading = false;
        splashData = {'error': e.toString()};
      });
    }
  }

  Gradient _parseGradient(Map<String, dynamic> background) {
    final type = background['type']?.toString() ?? 'gradient';
    final colors = (background['colors'] as List<dynamic>?)
            ?.map((c) => _parseColor(c.toString()))
            .toList() ??
        [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    
    final angle = (background['angle'] as num?)?.toDouble() ?? 0.0;
    
    // Convert angle to alignment
    final radians = angle * 3.14159 / 180;
    final begin = Alignment(
      -1 * (1 - radians / 3.14159),
      -1.0,
    );
    final end = Alignment(
      1 * (1 - radians / 3.14159),
      1.0,
    );

    return LinearGradient(
      colors: colors,
      begin: angle == 90 ? Alignment.topCenter : (angle == 0 ? Alignment.centerLeft : begin),
      end: angle == 90 ? Alignment.bottomCenter : (angle == 0 ? Alignment.centerRight : end),
    );
  }

  Color _parseColor(String colorString) {
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
      } else if (hex.length == 3) {
        // Support short hex codes like #FFF -> #FFFFFF
        final r = hex[0] + hex[0];
        final g = hex[1] + hex[1];
        final b = hex[2] + hex[2];
        return Color(int.parse('FF$r$g$b', radix: 16));
      }
    } catch (e) {
      print('Error parsing color $colorString: $e');
    }
    return const Color(0xFF6366F1);
  }

  // Calculate if we should use light or dark text based on background brightness
  Color _getTextColor(List<Color> backgroundColors) {
    // Get the average brightness of the gradient colors
    double totalBrightness = 0;
    for (var color in backgroundColors) {
      final brightness = (color.red * 299 + color.green * 587 + color.blue * 114) / 1000;
      totalBrightness += brightness;
    }
    final averageBrightness = totalBrightness / backgroundColors.length;
    
    // If background is light, use dark text. If dark, use light text.
    return averageBrightness > 128 ? const Color(0xFF1E293B) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    // Show error state
    if (splashData?['error'] != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      size: 72,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Unable to Load',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    splashData!['error'].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Go Back button (only show if can pop)
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
                          onPressed: () {
                            setState(() {
                              splashData = null;
                              loading = true;
                            });
                            _loadSplashData();
                          },
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
        ),
      );
    }
    
    if (loading || splashData == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    final background = splashData!['background'] as Map<String, dynamic>?;
    final appLogo = splashData!['app_logo']?.toString() ?? '';
    final appTitle = splashData!['app_title']?.toString() ?? '';
    final appName = splashData!['app_name']?.toString() ?? '';
    final appDescription = splashData!['app_description']?.toString() ?? '';
    final appVersion = splashData!['app_version']?.toString() ?? '';

    // Parse gradient colors to determine text color
    final gradientColors = background != null && background['colors'] != null
        ? (background['colors'] as List<dynamic>)
            .map((c) => _parseColor(c.toString()))
            .toList()
        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    
    final textColor = _getTextColor(gradientColors);

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

    // Apply animation if available
    if (_fadeAnimation != null) {
      content = FadeTransition(
        opacity: _fadeAnimation!,
        child: content,
      );
    }

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
}
