// presentation/screens/manager/reports/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<String> _reportTypes = [
    'Sales Report',
    'Order Report',
    'Product Performance',
    'Staff Performance'
  ];
  String _selectedReportType = 'Sales Report';

  // Date range
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  bool _isLoading = false;
  bool _reportGenerated = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: StringConstants.reports,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
      ),
      drawer: CustomDrawer(
        user: user,
        selectedIndex: 5, // Reports index
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportOptions(),
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Generating report...')
                : !_reportGenerated
                ? _buildWelcomeView()
                : _buildReportView(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report Type Dropdown
          Row(
            children: [
              const Icon(Icons.description, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Report Type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date Range Selection
          Row(
            children: [
              const Icon(Icons.date_range, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Date Range:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateRangePicker(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Generate Report Button
          CustomButton(
            text: 'Generate Report',
            onPressed: _generateReport,
            icon: Icons.insights,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedReportType,
          isExpanded: true,
          items: _reportTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedReportType = value!;
              _reportGenerated = false;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        // Start Date
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateFormat('MMM dd, yyyy').format(_startDate),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('to'),
        ),

        // End Date
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateFormat('MMM dd, yyyy').format(_endDate),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Select report type and date range',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Then click "Generate Report" to view your data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportView() {
    switch (_selectedReportType) {
      case 'Sales Report':
        return _buildSalesReport();
      case 'Order Report':
        return _buildOrderReport();
      case 'Product Performance':
        return _buildProductPerformanceReport();
      case 'Staff Performance':
        return _buildStaffPerformanceReport();
      default:
        return _buildSalesReport();
    }
  }

  Widget _buildSalesReport() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateRange = '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader('Sales Report', dateRange),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildSectionTitle('Sales by Category'),
          _buildChartPlaceholder('Pie chart showing sales by category', Icons.pie_chart),
          const SizedBox(height: 24),
          _buildSectionTitle('Daily Sales Trend'),
          _buildChartPlaceholder('Line chart showing daily sales trend', Icons.show_chart),
          const SizedBox(height: 24),
          _buildSectionTitle('Detailed Sales'),
          _buildTablePlaceholder(),
          const SizedBox(height: 32),
          _buildExportButtons(),
        ],
      ),
    );
  }

  Widget _buildOrderReport() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final dateRange = '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader('Order Report', dateRange),
          const SizedBox(height: 24),
          _buildOrderSummaryCards(),
          const SizedBox(height: 24),
          _buildSectionTitle('Orders by Status'),
          _buildChartPlaceholder('Pie chart showing order status distribution', Icons.pie_chart),
          const SizedBox(height: 24),
          _buildSectionTitle('Recent Orders'),
          _buildTablePlaceholder(),
          const SizedBox(height: 32),
          _buildExportButtons(),
        ],
      ),
    );
  }

  Widget _buildProductPerformanceReport() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Product Performance Report',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Generate Report',
            onPressed: _generateReport,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffPerformanceReport() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Staff Performance Report',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Generate Report',
            onPressed: _generateReport,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeader(String title, String dateRange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.date_range, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              dateRange,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildSummaryCard(
          title: 'Total Sales',
          value: NumberFormatter.formatCurrency(8247.50),
          icon: Icons.attach_money,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          title: 'Orders',
          value: '132',
          icon: Icons.receipt_long,
          color: AppTheme.accentColor,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          title: 'Avg Order Value',
          value: NumberFormatter.formatCurrency(62.48),
          icon: Icons.shopping_cart,
          color: AppTheme.secondaryColor,
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCards() {
    return Row(
      children: [
        _buildSummaryCard(
          title: 'Total Orders',
          value: '132',
          icon: Icons.receipt_long,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          title: 'Completed',
          value: '118 (89%)',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          title: 'Cancelled',
          value: '14 (11%)',
          icon: Icons.cancel,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(String message, IconData icon) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: AppTheme.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Expanded(child: Text('Column 1', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Column 2', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Column 3', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Column 4', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          for (var i = 0; i < 5; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('Data ${i+1}.1')),
                  Expanded(child: Text('Data ${i+1}.2')),
                  Expanded(child: Text('Data ${i+1}.3')),
                  Expanded(child: Text('Data ${i+1}.4')),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextButton(
              onPressed: () {},
              child: const Text('View All Data'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButtons() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomButton(
            text: 'Export PDF',
            onPressed: () => _exportReport(format: 'PDF'),
            icon: Icons.picture_as_pdf,
            isOutlined: true,
          ),
          const SizedBox(width: 16),
          CustomButton(
            text: 'Export Excel',
            onPressed: () => _exportReport(format: 'Excel'),
            icon: Icons.table_chart,
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate
        ? DateTime.now().subtract(const Duration(days: 365))
        : _startDate;
    final lastDate = isStartDate
        ? _endDate
        : DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
        _reportGenerated = false;
      });
    }
  }

  void _generateReport() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call or report generation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _reportGenerated = true;
      });
    });
  }

  void _exportReport({String format = 'PDF'}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting report as $format...')),
    );

    // Simulate export
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report exported as $format successfully')),
      );
    });
  }
}