import 'package:flutter/material.dart';
import 'package:ucbs_attendance_app/colors/colors.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  Navbar({super.key, required this.currentIndex, required this.onTap});

  final items = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.bar_chart_rounded,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: AppColors.bgLightDark,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
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
