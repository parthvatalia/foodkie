// presentation/screens/manager/staff/staff_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/common_widgets/search_bar.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({Key? key}) : super(key: key);

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final List<UserModel> _staffMembers = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  UserRole? _filterRole;

  @override
  void initState() {
    super.initState();
    _loadStaffMembers();
  }

  Future<void> _loadStaffMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, fetch staff members from a repository
      // For now, we'll use dummy data
      await Future.delayed(const Duration(seconds: 1));

      final now = DateTime.now();
      final dummyStaff = [
        UserModel(
          id: '1',
          name: 'John Smith',
          email: 'john.smith@foodkie.com',
          role: UserRole.manager,
          profileImage: null,
          phone: '+1 234 567 8901',
          createdAt: now.subtract(const Duration(days: 120)),
          updatedAt: now.subtract(const Duration(days: 10)),
        ),
        UserModel(
          id: '2',
          name: 'Emily Johnson',
          email: 'emily.johnson@foodkie.com',
          role: UserRole.waiter,
          profileImage: null,
          phone: '+1 234 567 8902',
          createdAt: now.subtract(const Duration(days: 90)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        UserModel(
          id: '3',
          name: 'Michael Williams',
          email: 'michael.williams@foodkie.com',
          role: UserRole.kitchen,
          profileImage: null,
          phone: '+1 234 567 8903',
          createdAt: now.subtract(const Duration(days: 60)),
          updatedAt: now.subtract(const Duration(days: 15)),
        ),
        UserModel(
          id: '4',
          name: 'Sarah Brown',
          email: 'sarah.brown@foodkie.com',
          role: UserRole.waiter,
          profileImage: null,
          phone: '+1 234 567 8904',
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        UserModel(
          id: '5',
          name: 'David Jones',
          email: 'david.jones@foodkie.com',
          role: UserRole.kitchen,
          profileImage: null,
          phone: '+1 234 567 8905',
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now,
        ),
      ];

      setState(() {
        _staffMembers.clear();
        _staffMembers.addAll(dummyStaff);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _searchStaff(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToAddStaff() {
    Navigator.pushNamed(context, RouteConstants.managerStaffAdd)
        .then((_) => _loadStaffMembers());
  }

  void _navigateToEditStaff(UserModel staff) {
    Navigator.pushNamed(
      context,
      RouteConstants.managerStaffEdit,
      arguments: staff,
    ).then((_) => _loadStaffMembers());
  }

  Future<void> _deleteStaff(UserModel staff) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Staff Member',
      message: 'Are you sure you want to delete "${staff.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onConfirm: () async {
        // In a real app, delete staff member from repository
        setState(() {
          _staffMembers.removeWhere((member) => member.id == staff.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff member deleted successfully')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: StringConstants.staff,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(),
            tooltip: 'Filter Staff',
          ),
        ],
      ),
      drawer: CustomDrawer(
        user: user,
        selectedIndex: 4, // Staff index
        onItemSelected: (index) {
          // Navigation logic
        },
        items: [
          DrawerItem(
            icon: Icons.dashboard,
            title: StringConstants.dashboard,
          ),
          DrawerItem(
            icon: Icons.category,
            title: StringConstants.categories,
          ),
          DrawerItem(
            icon: Icons.restaurant_menu,
            title: StringConstants.foodItems,
          ),
          DrawerItem(
            icon: Icons.table_bar,
            title: StringConstants.tables,
          ),
          DrawerItem(
            icon: Icons.people,
            title: StringConstants.staff,
          ),
          DrawerItem(
            icon: Icons.receipt_long,
            title: StringConstants.reports,
          ),
          DrawerItem(
            icon: Icons.analytics,
            title: StringConstants.analytics,
          ),
          DrawerItem(
            icon: Icons.settings,
            title: StringConstants.settings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          CustomSearchBar(
            hintText: 'Search staff by name or email...',
            onSearch: _searchStaff,
          ),

          // Role Filter Chips
          _buildRoleFilterChips(),

          // Staff List
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Loading staff members...')
                : _errorMessage != null
                ? ErrorDisplayWidget(
              message: 'Error loading staff members: $_errorMessage',
              onRetry: _loadStaffMembers,
            )
                : _buildStaffList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddStaff,
        child: const Icon(Icons.add),
        tooltip: 'Add Staff Member',
      ),
    );
  }

  Widget _buildRoleFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All filter option
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('All'),
              selected: _filterRole == null,
              onSelected: (selected) {
                setState(() {
                  _filterRole = null;
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          ),

          // Manager filter option
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('Managers'),
              selected: _filterRole == UserRole.manager,
              onSelected: (selected) {
                setState(() {
                  _filterRole = selected ? UserRole.manager : null;
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          ),

          // Waiter filter option
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('Waiters'),
              selected: _filterRole == UserRole.waiter,
              onSelected: (selected) {
                setState(() {
                  _filterRole = selected ? UserRole.waiter : null;
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          ),

          // Kitchen filter option
          FilterChip(
            label: const Text('Kitchen Staff'),
            selected: _filterRole == UserRole.kitchen,
            onSelected: (selected) {
              setState(() {
                _filterRole = selected ? UserRole.kitchen : null;
              });
            },
            backgroundColor: Colors.grey.shade200,
            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
            checkmarkColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    // Filter staff based on search query and role filter
    final filteredStaff = _staffMembers.where((staff) {
      bool matchesSearch = _searchQuery.isEmpty ||
          staff.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          staff.email.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesRole = _filterRole == null || staff.role == _filterRole;

      return matchesSearch && matchesRole;
    }).toList();

    if (filteredStaff.isEmpty) {
      return EmptyStateWidget(
        message: _filterRole != null
            ? 'No ${_filterRole!.name} staff members found'
            : 'No staff members found',
        actionLabel: 'Add Staff Member',
        onAction: _navigateToAddStaff,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredStaff.length,
      itemBuilder: (context, index) {
        final staff = filteredStaff[index];
        return _buildStaffCard(staff, index);
      },
    );
  }

  Widget _buildStaffCard(UserModel staff, int index) {
    return FadeAnimation(
      delay: 0.05 * index,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToEditStaff(staff),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Picture/Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _getRoleColor(staff.role).withOpacity(0.2),
                  backgroundImage: staff.profileImage != null
                      ? NetworkImage(staff.profileImage!)
                      : null,
                  child: staff.profileImage == null
                      ? Text(
                    staff.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(staff.role),
                    ),
                  )
                      : null,
                ),

                const SizedBox(width: 16),

                // Staff Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRoleColor(staff.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              staff.role.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getRoleColor(staff.role),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.phone,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            staff.phone ?? 'No phone',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToEditStaff(staff),
                      tooltip: 'Edit Staff',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteStaff(staff),
                      tooltip: 'Delete Staff',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.manager:
        return Colors.purple;
      case UserRole.waiter:
        return Colors.blue;
      case UserRole.kitchen:
        return Colors.orange;
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Name (A-Z)'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  Navigator.pop(context);
                  _sortStaffBy('name', true);
                },
              ),
              ListTile(
                title: const Text('Sort by Name (Z-A)'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  Navigator.pop(context);
                  _sortStaffBy('name', false);
                },
              ),
              ListTile(
                title: const Text('Sort by Role'),
                leading: const Icon(Icons.work),
                onTap: () {
                  Navigator.pop(context);
                  _sortStaffBy('role', true);
                },
              ),
              ListTile(
                title: const Text('Sort by Date Added (Newest First)'),
                leading: const Icon(Icons.calendar_today),
                onTap: () {
                  Navigator.pop(context);
                  _sortStaffBy('date', false);
                },
              ),
              ListTile(
                title: const Text('Sort by Date Added (Oldest First)'),
                leading: const Icon(Icons.calendar_today),
                onTap: () {
                  Navigator.pop(context);
                  _sortStaffBy('date', true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortStaffBy(String criteria, bool ascending) {
    setState(() {
      switch (criteria) {
        case 'name':
          _staffMembers.sort((a, b) => ascending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name));
          break;
        case 'role':
          _staffMembers.sort((a, b) => a.role.name.compareTo(b.role.name));
          break;
        case 'date':
          _staffMembers.sort((a, b) => ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt));
          break;
      }
    });
  }
}