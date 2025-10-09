import 'package:elibrary_desktop/screens/book_exchange_screen.dart';
import 'package:elibrary_desktop/screens/book_loan_screen.dart';
import 'package:elibrary_desktop/screens/book_screen.dart';
import 'package:elibrary_desktop/screens/complaint_screen.dart';
import 'package:elibrary_desktop/screens/forum_screen.dart';
import 'package:elibrary_desktop/screens/user_book_screen.dart';
import 'package:elibrary_desktop/screens/user_screen.dart';
import 'package:elibrary_desktop/widgets/admin_scaffold.dart';
import 'package:elibrary_desktop/screens/book_review_screen.dart';
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

      case 2:
        currentTitle = "Zamjena knjiga";
        currentScreen = const BookExchangeScreen();

      case 3:
        currentTitle = "Korisničke knjige";
        currentScreen = const UserBookListScreen();

      case 4:
        currentTitle = "Žalbe";
        currentScreen = const ComplaintScreen();
      
      case 5:
        currentTitle = "Evidencija posudbi";
        currentScreen = const BookLoanScreen();

      case 6:
        currentTitle = "Recenzije";
        currentScreen = const BookReviewScreen();

      case 7:
        currentTitle = "Forum";
        currentScreen = const ForumScreen();

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