import 'package:flutter/material.dart';
import 'package:elibrary_mobile/widgets/admin_scaffold.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    String currentTitle;

    switch (_selectedIndex) {
      default:
        currentTitle = "Početna";
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
    }

    return AdminScaffold(
      title: currentTitle,
      body: currentScreen,
      selectedIndex: _selectedIndex,
      onMenuTap: (index) {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
