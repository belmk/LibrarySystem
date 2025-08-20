import 'package:elibrary_desktop/screens/book_screen.dart';
import 'package:elibrary_desktop/screens/user_screen.dart';
import 'package:elibrary_desktop/widgets/admin_scaffold.dart';
import 'package:flutter/material.dart';

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
      case 0:
        currentTitle = "Korisnici";
        currentScreen = const UserListScreen();
      
      case 1:
        currentTitle = "Skladište";
        currentScreen = const BookListScreen();

      default:
        currentTitle = "Početna";
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
    }

    return AdminScaffold(
      title: currentTitle,
      body: currentScreen,
      selectedIndex: _selectedIndex,
      onMenuTap: (index) => setState(() => _selectedIndex = index),
    );
  }
}