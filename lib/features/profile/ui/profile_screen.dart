import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/logic/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the provider but don't 'watch' it (we just need the logout function)
    final authProvider = context.read<AuthProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // User Info Section
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFEFF4FF),
            child: Icon(Icons.person, size: 50, color: Color(0xFF1B6EF3)),
          ),
          const SizedBox(height: 15),
          Text(
            user?.email ?? "User Session",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),

          // Action List
          _buildProfileTile(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {},
          ),
          _buildProfileTile(
            icon: Icons.history,
            title: "Order History",
            onTap: () {},
          ),
          const Divider(indent: 20, endIndent: 20),

          // --- THE LOGOUT BUTTON ---
          _buildProfileTile(
            icon: Icons.logout_rounded,
            title: "Logout",
            color: Colors.redAccent, // Red to signal exit
            onTap: () => _showLogoutDialog(context, authProvider),
          ),
        ],
      ),
    );
  }

  // Helper for consistent list items
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF1E2A3A),
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  // A nice confirmation dialog to prevent accidental logouts
  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to end your session?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              auth.logout(); // This triggers the automatic navigation back to Login
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
