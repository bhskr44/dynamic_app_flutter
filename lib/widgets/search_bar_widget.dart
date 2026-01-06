
// filepath: lib/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';
import '../screens/dynamic_screen.dart';

class SearchBarWidget extends StatefulWidget {
  final Map<String, dynamic> widgetData;
  const SearchBarWidget({super.key, required this.widgetData});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _ctl = TextEditingController();
  bool _isFocused = false;

  void _onSubmit(String q) {
    final searchApi = widget.widgetData['search_api']?.toString();
    if (searchApi != null && searchApi.isNotEmpty) {
      final uri = searchApi.contains('?') ? '$searchApi&q=$q' : '$searchApi?q=$q';
      Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicScreen(apiUrl: uri)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No search API configured'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _isFocused 
                ? const Color(0xFF6366F1).withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
              blurRadius: _isFocused ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _ctl,
          onTap: () => setState(() => _isFocused = true),
          onTapOutside: (_) => setState(() => _isFocused = false),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _isFocused ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
              size: 24,
            ),
            suffixIcon: _ctl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () => setState(() => _ctl.clear()),
                  color: const Color(0xFF94A3B8),
                )
              : null,
            hintText: 'Search for anything...',
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSubmit,
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }
}