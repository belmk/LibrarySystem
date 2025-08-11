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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Scrollable NavigationRail
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onMenuTap,
                        labelType: NavigationRailLabelType.all,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.movie),
                            label: Text('Filmovi'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person),
                            label: Text('Glumci'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.theater_comedy),
                            label: Text('Kina'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.theaters),
                            label: Text('Kino sale'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.fastfood),
                            label: Text('Hrana/Piće'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.event),
                            label: Text('Projekcije'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.people),
                            label: Text('Korisnici'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.book),
                            label: Text('Rezervacije'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.category),
                            label: Text('Žanrovi'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.payment),
                            label: Text('Uplate'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.chair),
                            label: Text('Tipovi sjedišta'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.card_membership),
                            label: Text('Tipovi karata'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.discount),
                            label: Text('Popusti'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.report),
                            label: Text('Izvještaji'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const VerticalDivider(width: 1),
            Expanded(
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
                            builder:
                                (_) => AlertDialog(
                                  title: Text("Potvrdi odjavu"),
                                  content: Text(
                                    "Da li ste sigurni da se želite odjaviti?",
                                  ),
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
                                        Navigator.of(
                                          context,
                                        ).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
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
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}