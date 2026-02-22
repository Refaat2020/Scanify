import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OcrSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClear;
  final int matchCount;
  final int currentMatch;

  const OcrSearchBar({
    super.key,
    required this.onChanged,
    required this.onNext,
    required this.onPrevious,
    required this.onClear,
    required this.matchCount,
    required this.currentMatch,
  });

  @override
  State<OcrSearchBar> createState() => _OcrSearchBarState();
}

class _OcrSearchBarState extends State<OcrSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasQuery
              ? AppTheme.primary.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search in text...',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (v) {
                setState(() {});
                widget.onChanged(v);
              },
            ),
          ),
          // Match counter
          if (hasQuery && widget.matchCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${widget.currentMatch + 1}/${widget.matchCount}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ),
          // Prev / Next
          if (hasQuery && widget.matchCount > 0) ...[
            _NavButton(
              icon: Icons.keyboard_arrow_up_rounded,
              onTap: widget.onPrevious,
            ),
            _NavButton(
              icon: Icons.keyboard_arrow_down_rounded,
              onTap: widget.onNext,
            ),
          ],
          // Clear
          if (hasQuery)
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppTheme.textMuted,
              ),
              onPressed: () {
                _controller.clear();
                setState(() {});
                widget.onClear();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(icon, size: 18, color: AppTheme.textSecondary),
      ),
    );
  }
}
