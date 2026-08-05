/// Standard Material [BottomNavigationBar] wired to a [Scaffold] that swaps
/// [screens] by index. For a frosted-glass floating bar instead, use
/// [RHGlassBottomNavigationBar]/[RHGlassBottomNavigationScreen].
///
/// Work procedure:
/// 1. Build [screens] and [navItems] as parallel lists — index N of
///    [screens] shows when index N of [navItems] is tapped (an assertion
///    enforces equal length).
/// 2. Leave styling params at their defaults for standard Material look;
///    override [selectedItemColor]/[backgroundColor]/etc. to match a theme.
/// 3. Use as the entire screen (it owns the [Scaffold]) — don't nest it
///    inside another [Scaffold].
///
/// Usage:
/// ```dart
/// RHCustomBottomNavigationScreen(
///   screens: [HomeScreen(), SearchScreen(), ProfileScreen()],
///   navItems: const [
///     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
///     BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
///     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
///   ],
/// );
/// ```
library;

import 'package:flutter/material.dart';

class RHCustomBottomNavigationScreen extends StatefulWidget {
  /// Screens shown one at a time, indexed in parallel with [navItems].
  final List<Widget> screens;

  /// Nav bar items, indexed in parallel with [screens].
  final List<BottomNavigationBarItem> navItems;

  /// Tab selected on first build. Defaults to 0.
  final int initialIndex;

  /// Fixed vs shifting nav bar layout. Defaults to [BottomNavigationBarType.fixed].
  final BottomNavigationBarType navBarType;

  /// Nav bar background. Defaults to white.
  final Color backgroundColor;

  /// Color of the selected item's icon/label. Defaults to blueAccent.
  final Color selectedItemColor;

  /// Color of unselected items' icons/labels. Defaults to grey.
  final Color unselectedItemColor;

  /// Icon size. Defaults to 24.
  final double iconSize;

  /// Font size for the selected item's label. Defaults to 14.
  final double selectedFontSize;

  /// Font size for unselected items' labels. Defaults to 12.
  final double unselectedFontSize;

  /// Whether unselected items show their labels. Defaults to true.
  final bool showUnselectedLabels;

  /// Whether the selected item shows its label. Defaults to true.
  final bool showSelectedLabels;

  const RHCustomBottomNavigationScreen({
    super.key,
    required this.screens,
    required this.navItems,
    this.initialIndex = 0, // Default to index 0 if not provided
    this.navBarType = BottomNavigationBarType.fixed, // Default to fixed type
    this.backgroundColor = Colors.white, // Default background color
    this.selectedItemColor = Colors.blueAccent, // Default selected item color
    this.unselectedItemColor = Colors.grey, // Default unselected item color
    this.iconSize = 24.0, // Default icon size
    this.selectedFontSize = 14.0, // Default selected label font size
    this.unselectedFontSize = 12.0, // Default unselected label font size
    this.showUnselectedLabels = true, // Show unselected labels by default
    this.showSelectedLabels = true, // Show selected labels by default
  }) : assert(screens.length == navItems.length,
            "Screens and nav items count should be equal");

  @override
  // ignore: library_private_types_in_public_api
  _RHCustomBottomNavigationScreenState createState() =>
      _RHCustomBottomNavigationScreenState();
}

class _RHCustomBottomNavigationScreenState
    extends State<RHCustomBottomNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: widget.navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: widget.navBarType,
        backgroundColor: widget.backgroundColor,
        selectedItemColor: widget.selectedItemColor,
        unselectedItemColor: widget.unselectedItemColor,
        iconSize: widget.iconSize,
        selectedFontSize: widget.selectedFontSize,
        unselectedFontSize: widget.unselectedFontSize,
        showUnselectedLabels: widget.showUnselectedLabels,
        showSelectedLabels: widget.showSelectedLabels,
      ),
    );
  }
}
