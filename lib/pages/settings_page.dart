import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart';
import 'help_support_page.dart';

class SettingsPage extends StatelessWidget {
  final Function(String) navigateTo;
  final VoidCallback onLogout;

  const SettingsPage({
    super.key,
    required this.navigateTo,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.4),
                    width: 1,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Section
                    const Text(
                      'Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.person,
                            iconColor: Colors.black,
                            title: 'Profile Information',
                            subtitle: 'Update your personal details',
                            onTap: () => navigateTo('profile'),
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _buildSettingsItem(
                            icon: Icons.track_changes,
                            iconColor: Colors.black,
                            title: 'Goals & Targets',
                            subtitle: 'Set your fitness goals',
                            onTap: () => navigateTo('goals'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notifications Section
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Push Notifications',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    'Enable all notifications',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: true,
                            onChanged: (value) {},
                            activeColor: const Color(0xFF14B8A6),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Support Section
                    const Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            icon: Icons.help_outline,
                            iconColor: Colors.black,
                            title: 'Help & Support',
                            subtitle: 'Get help and contact us',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HelpSupportPage(),
                                ),
                              );
                            },
                          ),
                          Divider(height: 1, color: Colors.grey[200]),
                          _buildSettingsItem(
                            icon: Icons.logout,
                            iconColor: Colors.black,
                            title: 'Log Out',
                            subtitle: 'Sign out of your account',
                            titleColor: const Color(0xFFDC2626),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Log Out'),
                                  content: const Text('Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        onLogout();
                                      },
                                      child: const Text(
                                        'Log Out',
                                        style: TextStyle(color: Color(0xFFDC2626)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentPage: 'settings',
        onNavigate: navigateTo,
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor ?? const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
