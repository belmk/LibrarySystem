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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  tooltip: "Odjava",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Potvrdi odjavu"),
                        content: Text("Da li ste sigurni da se želite odjaviti?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Prekini"),
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
                            child: Text("Odjava"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            // Horizontal menu with equal-width buttons
            SizedBox(
              height: 60,
              child: Row(
                children: List.generate(_menuItems.length, (index) {
                  final item = _menuItems[index];
                  final isSelected = selectedIndex == index;

                  return Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
                        foregroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => onMenuTap(index),
                      icon: Icon(item['icon'], size: 20),
                      label: Text(
                        item['label'],
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
