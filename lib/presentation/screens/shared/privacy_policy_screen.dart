// presentation/screens/shared/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: StringConstants.privacyPolicy,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Privacy Policy'),
            _buildLastUpdated(context, 'Last Updated: March 1, 2025'),

            _buildSectionSubtitle(context, '1. Introduction'),
            _buildParagraph(context,
                'Welcome to Foodkie ("we," "our," or "us"). We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our restaurant management application.'
            ),
            _buildParagraph(context,
                'Please read this Privacy Policy carefully. By accessing or using our application, you acknowledge that you have read, understood, and agree to be bound by all the terms of this Privacy Policy. If you do not agree with our policies and practices, please do not use our application.'
            ),

            _buildSectionSubtitle(context, '2. Information We Collect'),
            _buildParagraph(context, 'We may collect the following types of information:'),
            _buildBulletPoint(context, 'Personal Information: Name, email address, phone number, and profile picture that you provide when you create an account.'),
            _buildBulletPoint(context, 'User Role Information: Your role in the restaurant (manager, waiter, or kitchen staff).'),
            _buildBulletPoint(context, 'Usage Data: Information about how you use our application, including order history, tables managed, and menu items created.'),
            _buildBulletPoint(context, 'Device Information: Information about your mobile device, including device type, operating system, and unique device identifiers.'),

            _buildSectionSubtitle(context, '3. How We Use Your Information'),
            _buildParagraph(context, 'We use the information we collect for various purposes, including:'),
            _buildBulletPoint(context, 'To provide and maintain our application'),
            _buildBulletPoint(context, 'To process and manage orders within your restaurant'),
            _buildBulletPoint(context, 'To notify you about changes to our application'),
            _buildBulletPoint(context, 'To allow you to participate in interactive features of our application'),
            _buildBulletPoint(context, 'To provide customer support'),
            _buildBulletPoint(context, 'To gather analysis or valuable information so that we can improve our application'),
            _buildBulletPoint(context, 'To monitor the usage of our application'),
            _buildBulletPoint(context, 'To detect, prevent and address technical issues'),

            _buildSectionSubtitle(context, '4. Data Security'),
            _buildParagraph(context, 'We implement appropriate technical and organizational measures to protect the security of your personal information. However, please be aware that no method of transmission over the internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your personal information, we cannot guarantee its absolute security.'),

            _buildSectionSubtitle(context, '5. Data Retention'),
            _buildParagraph(context, 'We will retain your personal information only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use your information to the extent necessary to comply with our legal obligations, resolve disputes, and enforce our policies.'),

            _buildSectionSubtitle(context, '6. Third-Party Services'),
            _buildParagraph(context, 'Our application may contain links to other websites or services that are not operated by us. If you click on a third-party link, you will be directed to that third party\'s site. We strongly advise you to review the Privacy Policy of every site you visit. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.'),

            _buildSectionSubtitle(context, '7. Children\'s Privacy'),
            _buildParagraph(context, 'Our application is not intended for use by children under the age of 13. We do not knowingly collect personally identifiable information from children under 13. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us.'),

            _buildSectionSubtitle(context, '8. Changes to This Privacy Policy'),
            _buildParagraph(context, 'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date at the top of this Privacy Policy. You are advised to review this Privacy Policy periodically for any changes.'),

            _buildSectionSubtitle(context, '9. Contact Us'),
            _buildParagraph(context, 'If you have any questions about this Privacy Policy, please contact us at:'),
            _buildParagraph(context, 'Email: privacy@foodkie.com'),
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