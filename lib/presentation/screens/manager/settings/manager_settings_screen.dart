// presentation/screens/manager/settings/manager_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';

class ManagerSettingsScreen extends StatefulWidget {
  const ManagerSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ManagerSettingsScreen> createState() => _ManagerSettingsScreenState();
}

class _ManagerSettingsScreenState extends State<ManagerSettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // In a real app, load settings from local storage or preferences
    // For now, we'll just use the default values set above
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: StringConstants.settings,
        showBackButton: false,
      ),
      drawer: CustomDrawer(
        user: user,
        selectedIndex: 7, // Settings index
        onItemSelected: (index) {
          // Navigation logic would go here
        },
        items: [
          DrawerItem(icon: Icons.dashboard, title: StringConstants.dashboard),
          DrawerItem(icon: Icons.category, title: StringConstants.categories),
          DrawerItem(icon: Icons.restaurant_menu, title: StringConstants.foodItems),
          DrawerItem(icon: Icons.table_bar, title: StringConstants.tables),
          DrawerItem(icon: Icons.people, title: StringConstants.staff),
          DrawerItem(icon: Icons.receipt_long, title: StringConstants.reports),
          DrawerItem(icon: Icons.analytics, title: StringConstants.analytics),
          DrawerItem(icon: Icons.settings, title: StringConstants.settings),
        ],
      ),
      body: _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      children: [
        _buildProfileCard(),
        const SizedBox(height: 16),
        _buildSettingsSection(
          title: 'Appearance',
          children: [
            _buildSwitchTile(
              title: StringConstants.darkMode,
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                // In a real app, apply theme change
              },
              icon: Icons.dark_mode,
            ),
            _buildLanguageTile(),
          ],
        ),
        _buildSettingsSection(
          title: 'Notifications',
          children: [
            _buildSwitchTile(
              title: StringConstants.notifications_,
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
              },
              icon: Icons.notifications,
            ),
            _buildSwitchTile(
              title: StringConstants.sound,
              value: _sound,
              onChanged: _notifications ? (value) {
                setState(() {
                  _sound = value;
                });
              } : null,
              icon: Icons.volume_up,
            ),
            _buildSwitchTile(
              title: StringConstants.vibration,
              value: _vibration,
              onChanged: _notifications ? (value) {
                setState(() {
                  _vibration = value;
                });
              } : null,
              icon: Icons.vibration,
            ),
          ],
        ),
        _buildSettingsSection(
          title: 'Security',
          children: [
            _buildNavigationTile(
              title: 'Change Password',
              icon: Icons.lock,
              onTap: () {
                // Navigate to change password screen
              },
            ),
            _buildNavigationTile(
              title: 'Privacy Settings',
              icon: Icons.security,
              onTap: () {
                // Navigate to privacy settings
              },
            ),
          ],
        ),
        _buildSettingsSection(
          title: 'About',
          children: [
            _buildNavigationTile(
              title: StringConstants.aboutApp,
              icon: Icons.info_outline,
              onTap: () {
                // Navigate to about screen
              },
            ),
            _buildNavigationTile(
              title: StringConstants.termsConditions,
              icon: Icons.description,
              onTap: () {
                // Navigate to terms screen
              },
            ),
            _buildNavigationTile(
              title: StringConstants.privacyPolicy,
              icon: Icons.privacy_tip,
              onTap: () {
                // Navigate to privacy policy screen
              },
            ),
            _buildVersionTile(),
          ],
        ),
        const SizedBox(height: 8),
        _buildLogoutButton(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileCard() {
    final user = Provider.of<AuthProvider>(context).user!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                onPressed: () {
                  // Navigate to edit profile screen
                },
                tooltip: 'Edit Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: onChanged != null ? AppTheme.primaryColor : Colors.grey),
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language, color: AppTheme.primaryColor),
      title: const Text(StringConstants.language),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        underline: const SizedBox(), // Remove underline
        items: _languages.map((language) {
          return DropdownMenuItem<String>(
            value: language,
            child: Text(language),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });
        },
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildVersionTile() {
    return ListTile(
      leading: const Icon(Icons.info, color: AppTheme.primaryColor),
      title: const Text(StringConstants.version),
      trailing: Text(
        'v${AppConstants.appVersion}',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(),
        icon: const Icon(Icons.logout),
        label: const Text(StringConstants.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: StringConstants.logout,
      message: StringConstants.logoutConfirmation,
      confirmLabel: StringConstants.logout,
      cancelLabel: StringConstants.cancel,
      isDestructive: true,
      icon: const Icon(Icons.logout, color: Colors.red),
      onConfirm: () {
        // Perform logout
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.logout();
      },
    );
  }
}