import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport80/providers/auth_provider.dart';
import 'package:sport80/utils/welcome_message.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ImageProvider? _profileImageProvider = const AssetImage('assets/images/sport80 logo.png');
    bool _isLoading = true;
    final authService = ref.watch(authProvider); // Watching AuthService
    final user = authService.currentUser; // Directly accessing the current user
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>(); // Key to control the drawer

    return Scaffold(
      key: scaffoldKey, // Assign the key to Scaffold
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text(user?.email ?? "guest@example.com"),
              accountName: Text(user?.displayName ?? ""),
              currentAccountPicture: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageProvider,
                child: _profileImageProvider == const AssetImage('assets/placeholder.png') ? const Icon(Icons.person, size: 60) : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: () async {
                Navigator.pop(context); // Close the drawer first
                authService.signOut();
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen after sign out
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const Spacer(), // Adds a spacer
                TextButton(
                  onPressed: () {},
                  child: const Text('Events', style: TextStyle(color: Colors.white)),
                ),
                const Spacer(), // Adds a spacer
                TextButton(
                  onPressed: () {},
                  child: const Text('Runs', style: TextStyle(color: Colors.white)),
                ),
                const Spacer(), // Adds a spacer
                TextButton(
                  onPressed: () {},
                  child: const Text('Community', style: TextStyle(color: Colors.white)),
                ),
                const Spacer(), // Adds a spacer
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Align(
              alignment: Alignment.center,
              child: WelcomeMessage(email: user?.email ?? "Guest"),
            ),
          ),
        ],
      ),
    );
  }
}
