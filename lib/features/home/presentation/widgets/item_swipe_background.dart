import 'package:flutter/material.dart';

class ItemSwipeBackground extends StatelessWidget {
  const ItemSwipeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
          SizedBox(height: 3),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
