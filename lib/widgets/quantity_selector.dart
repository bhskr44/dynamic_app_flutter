import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final int min;
  final int max;
  final Function(int) onChanged;

  const QuantitySelector({
    super.key,
    this.initialQuantity = 1,
    this.min = 1,
    this.max = 99,
    required this.onChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _increment() {
    if (_quantity < widget.max) {
      setState(() => _quantity++);
      widget.onChanged(_quantity);
    }
  }

  void _decrement() {
    if (_quantity > widget.min) {
      setState(() => _quantity--);
      widget.onChanged(_quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove,
            onPressed: _quantity > widget.min ? _decrement : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add,
            onPressed: _quantity < widget.max ? _increment : null,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onPressed}) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }
}
