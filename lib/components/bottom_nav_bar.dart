// components/bottom_nav_bar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  void _showProfileMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(button.size.width - 180, -160), ancestor: overlay),
        button.localToGlobal(Offset(button.size.width, -140), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      items: [
        PopupMenuItem(
          value: 1,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person, size: 20),
            title: const Text('Profile', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/get_email');
            },
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock, size: 20),
            title: const Text('Change Password', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/fpassword');
            },
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.exit_to_app, size: 20),
            title: const Text('Logout', style: TextStyle(fontSize: 14)),
            onTap: () {
              Navigator.pop(context);
              _showLogoutConfirmation(context);
            },
          ),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.hive),
          label: 'Hives',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Insights',
        ),
        BottomNavigationBarItem(
          icon: GestureDetector(
            onTap: () => _showProfileMenu(context),
            child: const Icon(Icons.person),
          ),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 3) {
          // Profile index - handled by the GestureDetector above
        } else {
          onItemSelected(index);
        }
      },
    );
  }
}