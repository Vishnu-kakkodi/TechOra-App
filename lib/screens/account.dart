import 'package:flutter/material.dart';
import 'package:project/screens/change_password.dart';
import 'package:project/screens/leader_board.dart';
import 'package:project/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Sample user data
  final String userName = "John Doe";
  final String userEmail = "john.doe@example.com";
  final String userAvatar = "https://randomuser.me/api/portraits/men/1.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildNavigationOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(userAvatar),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationOptions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            _buildNavigationItem(
              icon: Icons.person,
              title: 'My Profile',
              onTap: () => _navigateTo(context, 'profile'),
            ),
            _buildDivider(),
            _buildNavigationItem(
              icon: Icons.shopping_bag,
              title: 'My Orders',
              onTap: () => _navigateTo(context, 'orders'),
            ),
            _buildDivider(),
            _buildNavigationItem(
              icon: Icons.school,
              title: 'My Courses',
              onTap: () => _navigateTo(context, 'courses'),
            ),
            _buildDivider(),
            _buildNavigationItem(
              icon: Icons.favorite,
              title: 'Wishlist',
              onTap: () => _navigateTo(context, 'wishlist'),
            ),
            _buildDivider(),
            _buildNavigationItem(
              icon: Icons.leaderboard,
              title: 'Leaderboard',
                            onTap: () {
                // Navigate to the ChangePasswordScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildNavigationItem(
              icon: Icons.lock,
              title: 'Change Password',
              onTap: () {
                // Navigate to the ChangePasswordScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildNavigationItem(
              icon: Icons.exit_to_app,
              title: 'Logout',
              textColor: Colors.red[700],
              onTap: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
  }

  void _navigateTo(BuildContext context, String route) {
    // This is where you would navigate to the specific page
    // For demonstration, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $route page'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear stored user session from SharedPreferences
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.clear();

                // Close the dialog
                Navigator.of(context).pop();

                // Show logout confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Successfully logged out"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                // Navigate to login screen and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
