import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedItem;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GNav(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          gap: 6,
          iconSize: 24,
          textSize: 14,
          tabBorderRadius: 50,
          backgroundColor: Colors.transparent,
          activeColor: Colors.white,
          color: Colors.white60,
          tabBackgroundGradient: LinearGradient(
            colors: [
              Colors.deepOrange[400]!,
              Colors.deepOrangeAccent.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          tabs: const [
            GButton(icon: CupertinoIcons.home, text: 'Home'),
            GButton(icon: CupertinoIcons.app_fill, text: 'All'),
            GButton(icon: CupertinoIcons.heart_circle, text: 'Fav'),
            GButton(icon: CupertinoIcons.cart_fill, text: 'Cart'),
          ],
          selectedIndex: selectedItem,
          onTabChange: onTap,
        ),
      ),
    );
  }
}