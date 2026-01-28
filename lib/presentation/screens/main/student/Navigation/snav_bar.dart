import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/presentation/widgets/common/app_colors.dart';

class SnavBar extends StatefulWidget {
  final Function(int) onTap;
  final int currentIndex;
  const SnavBar({super.key, required this.onTap, required this.currentIndex});

  @override
  State<SnavBar> createState() => _SnavBarState();
}

class _SnavBarState extends State<SnavBar> {
  final items = [Icons.home, Icons.search, Icons.class_, Icons.person];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: AppColors.bgLightDark,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isActive = index == widget.currentIndex;
          return GestureDetector(
            onTap: () => widget.onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? AppColors.accentyellow : Colors.transparent,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                items[index],
                size: 26,
                color: isActive
                    ? AppColors.bgLightDark
                    : AppColors.textSecondary,
              ),
            ),
          );
        }),
      ),
    );
  }
}
