// presentation/screens/shared/about_screen.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: StringConstants.aboutApp,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 24),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  AssetsConstants.logoIconPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // App Name
            Text(
              StringConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 8),

            // App Slogan
            Text(
              StringConstants.appSlogan,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Version Info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${StringConstants.version} ${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 32),

            // App Description
            Text(
              StringConstants.appDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Features Section
            _buildFeatureSection(context),

            const SizedBox(height: 32),

            // Company Info
            Text(
              '© ${DateTime.now().year} ${StringConstants.companyName}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'All Rights Reserved',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.fastfood,
        'title': 'Menu Management',
        'description': 'Create and manage food items and categories',
      },
      {
        'icon': Icons.table_bar,
        'title': 'Table Management',
        'description': 'Track and manage restaurant tables',
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Order Processing',
        'description': 'Take orders and track order statuses in real-time',
      },
      {
        'icon': Icons.analytics,
        'title': 'Performance Analytics',
        'description': 'View sales data and performance metrics',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureItem(
          context,
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
        )),
      ],
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}