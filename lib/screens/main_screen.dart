import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

/// MainScreen is stateless — all navigation state lives inside BottomNavbar.
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomNavbar();
  }
}
