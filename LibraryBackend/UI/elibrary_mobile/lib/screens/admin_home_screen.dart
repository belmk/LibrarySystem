import 'package:elibrary_mobile/screens/book_list_screen.dart';
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
      case 0: //Knjige
        currentTitle = 'Knjige';
        currentScreen = const BookListScreen();
        break;

      case 1: //Kor. knjige
        currentTitle = 'Korisničke knjige';
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
        break;

      case 2: //Korisnici
        currentTitle = 'Korisnici';
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
        break;

      case 3: //Moje knjige
        currentTitle = 'Moje knjige';
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
        break;

      case 4: //Clanarina
        currentTitle = 'Članarina';
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
        break;

      case 5: //Obavijesti
        currentTitle = 'Obavijesti';
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
        break;

      case 6: //Profil
        currentTitle = 'Profil';
        currentScreen = const Center(child: Text("Nepoznata sekcija"));
        break;
        
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
