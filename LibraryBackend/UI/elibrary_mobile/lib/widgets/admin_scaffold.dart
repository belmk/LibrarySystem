import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/util.dart';
import '../screens/login_screen.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onMenuTap;

  const AdminScaffold({
    Key? key,
    required this.title,
    required this.body,
    required this.selectedIndex,
    required this.onMenuTap,
  }) : super(key: key);

  static const List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.menu_book_rounded, 'label': 'Knjige'},
    {'icon': Icons.library_books_rounded, 'label': 'Korisničke knjige'},
    {'icon': Icons.group_rounded, 'label': 'Korisnici'},
    {'icon': Icons.bookmark_rounded, 'label': 'Moje knjige'},
    {'icon': Icons.card_membership_rounded, 'label': 'Članarina'},
    {'icon': Icons.notifications_rounded, 'label': 'Obavijesti'},
    {'icon': Icons.person_rounded, 'label': 'Profil'},
  ];

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Potvrdi odjavu"),
        content: const Text("Da li ste sigurni da se želite odjaviti?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Prekini"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Authorization.username = null;
              Authorization.password = null;

              context.read<AuthProvider>().logout();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Odjava"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>(); 
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Otvori izbornik',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Odjava",
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.library_books,
                      size: 50,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Dobrodošli, ${user?.username ?? 'Korisnik'}",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    final isSelected = selectedIndex == index;

                    return ListTile(
                      leading: Icon(
                        item['icon'],
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      title: Text(
                        item['label'],
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () => onMenuTap(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: body),
    );
  }
}
