// presentation/screens/shared/help_screen.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Help & Support',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Help Categories
            _buildHelpSection(
              context,
              title: 'Frequently Asked Questions',
              icon: Icons.question_answer,
              children: _buildFaqItems(context),
            ),

            const SizedBox(height: 24),

            _buildHelpSection(
              context,
              title: 'Contact Support',
              icon: Icons.contact_support,
              children: [
                _buildContactItem(
                  context,
                  title: 'Email Support',
                  subtitle: 'support@foodkie.com',
                  icon: Icons.email,
                  onTap: () {
                    // Implement email support action
                  },
                ),
                _buildContactItem(
                  context,
                  title: 'Phone Support',
                  subtitle: '+1 (123) 456-7890',
                  icon: Icons.phone,
                  onTap: () {
                    // Implement phone support action
                  },
                ),
                _buildContactItem(
                  context,
                  title: 'Live Chat',
                  subtitle: 'Available 24/7',
                  icon: Icons.chat,
                  onTap: () {
                    // Implement live chat action
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildHelpSection(
              context,
              title: 'User Guides',
              icon: Icons.menu_book,
              children: [
                _buildGuideItem(
                  context,
                  title: 'Manager Guide',
                  subtitle: 'Learn how to manage your restaurant',
                  icon: Icons.admin_panel_settings,
                ),
                _buildGuideItem(
                  context,
                  title: 'Waiter Guide',
                  subtitle: 'Learn how to take and manage orders',
                  icon: Icons.room_service,
                ),
                _buildGuideItem(
                  context,
                  title: 'Kitchen Guide',
                  subtitle: 'Learn how to process orders in the kitchen',
                  icon: Icons.restaurant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  List<Widget> _buildFaqItems(BuildContext context) {
    final faqItems = [
      {
        'question': 'How do I create a new order?',
        'answer':
        'To create a new order, navigate to the Waiter section, select a table, choose food items from the menu, specify quantities, and click "Place Order".',
      },
      {
        'question': 'How do I add a new food item?',
        'answer':
        'In the Manager section, go to "Food Items", click the "+" button, fill in the details including name, price, description, category, and image, then save the item.',
      },
      {
        'question': 'How do I view kitchen orders?',
        'answer':
        'In the Kitchen section, you can see all pending orders. You can accept an order, mark it as "Preparing", and then as "Ready" when it\'s complete.',
      },
      {
        'question': 'How do I reset my password?',
        'answer':
        'On the login screen, click "Forgot Password", enter your email address, and follow the instructions sent to your email to reset your password.',
      },
      {
        'question': 'How do I generate reports?',
        'answer':
        'In the Manager section, navigate to "Reports" where you can select the report type, date range, and other filters to generate detailed business reports.',
      },
    ];

    return faqItems.map((item) => _buildFaqItem(
      context,
      question: item['question']!,
      answer: item['answer']!,
    )).toList();
  }

  Widget _buildFaqItem(
      BuildContext context, {
        required String question,
        required String answer,
      }) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
      tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      childrenPadding: EdgeInsets.zero,
    );
  }

  Widget _buildContactItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildGuideItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.download, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}