
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

  void _onSubmit(String q) {
    final searchApi = widget.widgetData['search_api']?.toString();
    if (searchApi != null && searchApi.isNotEmpty) {
      final uri = searchApi.contains('?') ? '$searchApi&q=$q' : '$searchApi?q=$q';
      Navigator.push(context, MaterialPageRoute(builder: (_) => DynamicScreen(apiUrl: uri)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No search API configured')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _ctl,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: _onSubmit,
      ),
    );
  }
}