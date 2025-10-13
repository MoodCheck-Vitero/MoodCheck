import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/account_screen.dart';
import '../widgets/navbar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;

  late List<Widget> _screens;

  late AnimationController _controller;
  late Animation<Offset> _currentAnimation;
  late Animation<Offset> _previousAnimation;

  @override
  void initState() {
    super.initState();

    _screens = [
      const HomeScreen(),
      const InsightsScreen(),
      const CalendarScreen(),
      const AccountScreen(),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _currentAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
    _previousAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;

      bool slideLeft = _selectedIndex > _previousIndex;

      _currentAnimation = Tween<Offset>(
        begin: Offset(slideLeft ? 1.0 : -1.0, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _previousAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(slideLeft ? -1.0 : 1.0, 0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SlideTransition(
            position: _previousAnimation,
            child: _screens[_previousIndex],
          ),
          SlideTransition(
            position: _currentAnimation,
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}