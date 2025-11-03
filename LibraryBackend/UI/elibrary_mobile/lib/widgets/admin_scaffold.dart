import 'package:flutter/material.dart';
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
    {'icon': Icons.people, 'label': 'Korisnici'},
    {'icon': Icons.inventory, 'label': 'Skladište'},
    {'icon': Icons.swap_horiz, 'label': 'Zamjena knjiga'},
    {'icon': Icons.menu_book, 'label': 'Korisničke knjige'},
    {'icon': Icons.report_problem, 'label': 'Žalbe'},
    {'icon': Icons.assignment, 'label': 'Evidencija posudbi'},
    {'icon': Icons.rate_review, 'label': 'Recenzije'},
    {'icon': Icons.forum, 'label': 'Forum'},
    {'icon': Icons.dashboard, 'label': 'Dashboard'},
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
                  children: [
                    Icon(Icons.admin_panel_settings,
                        size: 50,
                        color: Theme.of(context).colorScheme.onPrimaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "eLibrary Admin",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
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
