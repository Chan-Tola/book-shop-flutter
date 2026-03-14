import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../shared/layouts/main_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the provider but don't 'watch' it (we just need the logout function)
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainLayout()),
              );
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline_rounded,
            title: "Account",
            onTap: () {},
          ),
          // _buildSettingsTile(
          //   icon: Icons.notifications_none_rounded,
          //   title: "Notification",
          //   onTap: () {},
          // ),
          // _buildSettingsTile(
          //   icon: Icons.monitor_outlined,
          //   title: "Display",
          //   onTap: () {},
          // ),
          // _buildSettingsTile(
          //   icon: Icons.lock_outline_rounded,
          //   title: "Privacy",
          //   onTap: () {},
          // ),J
          // _buildSettingsTile(
          //   icon: Icons.credit_card_outlined,
          //   title: "Payment",
          //   onTap: () {},
          // ),
          // _buildSettingsTile(
          //   icon: Icons.language_outlined,
          //   title: "Language",
          //   onTap: () {},
          // ),
          // _buildSettingsTile(
          //   icon: Icons.error_outline_rounded, // Exclamation in circle
          //   title: "Help",
          //   onTap: () {},
          // ),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: "Logout",
            onTap: () => _showLogoutDialog(context, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: Colors.black87, size: 26),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.black54,
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
              auth.logout(
                context: context,
              ); // This triggers the automatic navigation back to Login
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
