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
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.bgLightDark,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accentBlue.withOpacity(0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                items[index],
                size: 26,

                color: isActive
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          );
        }),
      ),
    );
  }
}
