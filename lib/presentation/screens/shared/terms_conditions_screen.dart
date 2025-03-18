// presentation/screens/shared/terms_conditions_screen.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: StringConstants.termsConditions,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Terms & Conditions'),
            _buildLastUpdated(context, 'Last Updated: March 1, 2025'),

            _buildSectionSubtitle(context, '1. Acceptance of Terms'),
            _buildParagraph(context,
                'By downloading, installing, or using the Foodkie application ("Application"), you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree to these Terms, you should not use the Application.'
            ),
            _buildParagraph(context,
                'These Terms constitute a legally binding agreement between you and Foodkie ("we," "us," or "our") regarding your use of the Application. Please read them carefully.'
            ),

            _buildSectionSubtitle(context, '2. Description of Service'),
            _buildParagraph(context,
                'Foodkie is a restaurant management application designed to help restaurant owners, managers, waiters, and kitchen staff manage their operations efficiently. The Application offers features including menu management, order processing, table management, and staff coordination.'
            ),

            _buildSectionSubtitle(context, '3. User Accounts'),
            _buildParagraph(context, 'To access certain features of the Application, you must create a user account. When creating your account, you agree to:'),
            _buildBulletPoint(context, 'Provide accurate, current, and complete information'),
            _buildBulletPoint(context, 'Maintain and promptly update your account information'),
            _buildBulletPoint(context, 'Keep your password secure and confidential'),
            _buildBulletPoint(context, 'Be responsible for all activities that occur under your account'),
            _buildBulletPoint(context, 'Notify us immediately of any unauthorized use of your account'),

            _buildSectionSubtitle(context, '4. User Roles and Permissions'),
            _buildParagraph(context, 'The Application offers different user roles (Manager, Waiter, Kitchen Staff) with varying levels of access and permissions. You agree to:'),
            _buildBulletPoint(context, 'Only access features and data appropriate for your assigned role'),
            _buildBulletPoint(context, 'Not attempt to bypass role-based restrictions or access controls'),
            _buildBulletPoint(context, 'Use your assigned role responsibly and for its intended purpose'),

            _buildSectionSubtitle(context, '5. License and Restrictions'),
            _buildParagraph(context,
                'Subject to these Terms, we grant you a limited, non-exclusive, non-transferable, non-sublicensable license to download, install, and use the Application for your internal business purposes.'
            ),
            _buildParagraph(context, 'You agree not to:'),
            _buildBulletPoint(context, 'Copy, modify, or create derivative works of the Application'),
            _buildBulletPoint(context, 'Reverse engineer, decompile, or disassemble the Application'),
            _buildBulletPoint(context, 'Remove or alter any proprietary notices or labels on the Application'),
            _buildBulletPoint(context, 'Use the Application for any illegal purpose'),
            _buildBulletPoint(context, 'Transmit any viruses, worms, defects, or harmful code through the Application'),
            _buildBulletPoint(context, 'Use the Application in any manner that could damage, disable, or impair the Application'),

            _buildSectionSubtitle(context, '6. Data and Privacy'),
            _buildParagraph(context,
                'Your use of the Application is also governed by our Privacy Policy, which is incorporated into these Terms by reference. By using the Application, you consent to the collection, use, and sharing of your information as described in the Privacy Policy.'
            ),

            _buildSectionSubtitle(context, '7. Intellectual Property'),
            _buildParagraph(context,
                'The Application, including all content, features, and functionality, is owned by us or our licensors and is protected by intellectual property laws. You agree not to use our trademarks, service marks, or trade names without our prior written consent.'
            ),

            _buildSectionSubtitle(context, '8. Termination'),
            _buildParagraph(context, 'We may terminate or suspend your access to the Application immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach these Terms.'),
            _buildParagraph(context, 'Upon termination, your right to use the Application will immediately cease.'),

            _buildSectionSubtitle(context, '9. Disclaimer of Warranties'),
            _buildParagraph(context,
                'THE APPLICATION IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT ANY WARRANTIES OF ANY KIND. WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.'
            ),

            _buildSectionSubtitle(context, '10. Limitation of Liability'),
            _buildParagraph(context,
                'IN NO EVENT SHALL WE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL OR PUNITIVE DAMAGES, INCLUDING WITHOUT LIMITATION, LOSS OF PROFITS, DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM YOUR ACCESS TO OR USE OF OR INABILITY TO ACCESS OR USE THE APPLICATION.'
            ),

            _buildSectionSubtitle(context, '11. Indemnification'),
            _buildParagraph(context,
                'You agree to indemnify, defend, and hold harmless Foodkie and its officers, directors, employees, agents, and affiliates from and against any claims, liabilities, damages, losses, and expenses, including reasonable attorneys\' fees, arising out of or in any way connected with your access to or use of the Application or your violation of these Terms.'
            ),

            _buildSectionSubtitle(context, '12. Changes to Terms'),
            _buildParagraph(context,
                'We reserve the right to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms on the Application. Your continued use of the Application after any such changes constitutes your acceptance of the new Terms.'
            ),

            _buildSectionSubtitle(context, '13. Governing Law'),
            _buildParagraph(context,
                'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which our company is registered, without regard to its conflict of law provisions.'
            ),

            _buildSectionSubtitle(context, '14. Contact Information'),
            _buildParagraph(context, 'If you have any questions about these Terms, please contact us at:'),
            _buildParagraph(context, 'Email: terms@foodkie.com'),
            _buildParagraph(context, 'Address: 123 Restaurant Avenue, Foodie City, FC 12345'),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildLastUpdated(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSectionSubtitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}