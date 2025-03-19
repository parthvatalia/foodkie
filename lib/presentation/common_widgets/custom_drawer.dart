// presentation/common_widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';

import '../../core/constants/route_constants.dart';

class CustomDrawer extends StatelessWidget {
  final UserModel user;
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<DrawerItem> items;

  const CustomDrawer({
    Key? key,
    required this.user,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with User Info
          _buildDrawerHeader(context),

          // Divider
          const Divider(height: 1),

          // Drawer Items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildDrawerItem(
                  context: context,
                  icon: item.icon,
                  title: item.title,
                  isSelected: index == selectedIndex,
                  onTap: () {
                    // Close drawer
                    //Navigator.pop(context);

                    // Handle item selection
                    onItemSelected(index);
                  },
                );
              },
            ),
          ),

          // Divider
          const Divider(height: 1),

          // Logout Button
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Text(user.email, style: const TextStyle(fontSize: 14)),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage:
            user.profileImage != null ? NetworkImage(user.profileImage!) : null,
        child:
            user.profileImage == null
                ? Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                )
                : null,
      ),
      decoration: BoxDecoration(color: AppTheme.primaryColor),
      otherAccountsPictures: [
        Tooltip(
          message: _getRoleTooltip(user.role),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              _getRoleIcon(user.role),
              color: AppTheme.primaryColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade900,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Logout',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        // Show confirmation dialog
        ConfirmationDialog.show(
          context: context,
          title: 'Logout',
          message: 'Are you sure you want to logout?',
          confirmLabel: 'Logout',
          cancelLabel: 'Cancel',
          isDestructive: true,
          icon: const Icon(Icons.logout, color: Colors.red),
          onConfirm: () async{
           await authProvider.logout(context);
           Navigator.of(context).pushNamedAndRemoveUntil(
             RouteConstants.splash,
                 (route) => false, // This removes all existing routes
           );

          },
        );
      },
    );
  }

  String _getRoleTooltip(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return 'Manager';
      case UserRole.waiter:
        return 'Waiter';
      case UserRole.kitchen:
        return 'Kitchen Staff';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return Icons.admin_panel_settings;
      case UserRole.waiter:
        return Icons.room_service;
      case UserRole.kitchen:
        return Icons.restaurant;
    }
  }
}

class DrawerItem {
  final IconData icon;
  final String title;

  DrawerItem({required this.icon, required this.title});
}
