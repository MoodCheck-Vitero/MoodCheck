import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xff009d03);

    return BottomAppBar(
      color: Colors.white,
      elevation: 6,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', 0, activeColor),
            _buildNavItem(Icons.show_chart_rounded, 'Insights', 1, activeColor),
            _buildNavItem(Icons.calendar_month_rounded, 'Calendar', 2, activeColor),
            _buildNavItem(Icons.person_2, 'Account', 3, activeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color activeColor,
  ) {
    final bool isSelected = selectedIndex == index;
    final Color color = isSelected ? activeColor : Colors.grey;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        splashColor: activeColor.withOpacity(0.2),
        highlightColor: activeColor.withOpacity(0.1),
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}