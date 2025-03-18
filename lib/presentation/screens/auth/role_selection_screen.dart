// presentation/screens/auth/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _confirmSelection() {
    if (_selectedRole != null) {
      Navigator.of(context).pop(_selectedRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.selectRole),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select your role in the restaurant',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Your role determines what features you can access',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Manager Role
              _buildRoleCard(
                role: UserRole.manager,
                title: StringConstants.managerTitle,
                description: StringConstants.managerDescription,
                icon: Icons.admin_panel_settings,
              ),

              const SizedBox(height: 16),

              // Waiter Role
              _buildRoleCard(
                role: UserRole.waiter,
                title: StringConstants.waiterTitle,
                description: StringConstants.waiterDescription,
                icon: Icons.room_service,
              ),

              const SizedBox(height: 16),

              // Kitchen Role
              _buildRoleCard(
                role: UserRole.kitchen,
                title: StringConstants.kitchenTitle,
                description: StringConstants.kitchenDescription,
                icon: Icons.restaurant,
              ),

              const Spacer(),

              // Confirm Button
              CustomButton(
                text: StringConstants.confirm,
                onPressed: _confirmSelection,
                disabled: _selectedRole == null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _selectRole(role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Checkbox
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}