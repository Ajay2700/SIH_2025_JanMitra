import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/data/models/user_model.dart';
import 'package:jan_mitra/data/models/issue_model.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:jan_mitra/data/services/issue_service.dart';
import 'package:jan_mitra/core/ui/app_card.dart';
import 'package:jan_mitra/core/ui/app_button.dart';
import 'package:jan_mitra/core/ui/status_badge.dart';
import 'package:jan_mitra/modules/citizen/views/user_profile_view.dart';
import 'package:jan_mitra/modules/citizen/views/report_issue_view.dart';
import 'package:jan_mitra/routes/app_routes.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class EnhancedHomeView extends StatefulWidget {
  @override
  _EnhancedHomeViewState createState() => _EnhancedHomeViewState();
}

class _EnhancedHomeViewState extends State<EnhancedHomeView> {
  final FirebaseAuthService _authService = Get.find<FirebaseAuthService>();
  final IssueService _issueService = Get.find<IssueService>();

  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<IssueModel> recentIssues = <IssueModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Load all users
      await _loadAllUsers();

      // Load recent issues
      await _loadRecentIssues();
    } catch (e) {
      errorMessage.value = 'Failed to load data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadAllUsers() async {
    try {
      // This would normally fetch from your user service
      // For now, we'll create some sample users
      final sampleUsers = [
        UserModel(
          id: '1',
          email: 'ajjukumar1012@gmail.com',
          name: 'Ajjukumar Patel',
          phone: '+91-9876543210',
          role: 'citizen',
          createdAt: DateTime.now().subtract(Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        UserModel(
          id: '2',
          email: 'sneha.gupta@gmail.com',
          name: 'Sneha Gupta',
          phone: '+91-9876543211',
          role: 'citizen',
          createdAt: DateTime.now().subtract(Duration(days: 25)),
          updatedAt: DateTime.now(),
        ),
        UserModel(
          id: '3',
          email: 'rajesh.kumar@gov.in',
          name: 'Rajesh Kumar',
          phone: '+91-9876543212',
          role: 'admin',
          createdAt: DateTime.now().subtract(Duration(days: 60)),
          updatedAt: DateTime.now(),
        ),
        UserModel(
          id: '4',
          email: 'priya.sharma@gov.in',
          name: 'Priya Sharma',
          phone: '+91-9876543213',
          role: 'admin',
          createdAt: DateTime.now().subtract(Duration(days: 45)),
          updatedAt: DateTime.now(),
        ),
        UserModel(
          id: '5',
          email: 'ramesh.worker@municipal.gov.in',
          name: 'Ramesh Kumar',
          phone: '+91-9876543214',
          role: 'worker',
          createdAt: DateTime.now().subtract(Duration(days: 20)),
          updatedAt: DateTime.now(),
        ),
      ];

      allUsers.value = sampleUsers;
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _loadRecentIssues() async {
    try {
      final issues = await _issueService.getAllIssues();
      recentIssues.value = issues.take(5).toList();
    } catch (e) {
      print('Error loading issues: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jan Mitra'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              final currentUser = _authService.getCurrentUser();
              if (currentUser != null) {
                Get.to(() => UserProfileView(user: currentUser));
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  errorMessage.value,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(onPressed: _loadData, child: Text('Retry')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(context),
                SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(context),
                SizedBox(height: 24),

                // All Users Section
                _buildUsersSection(context),
                SizedBox(height: 24),

                // Recent Issues Section
                _buildRecentIssuesSection(context),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => ReportIssueView()),
        icon: Icon(Icons.add),
        label: Text('Report Issue'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final currentUser = _authService.getCurrentUser();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Jan Mitra',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Empowering Citizens, Improving Cities',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          if (currentUser != null) ...[
            SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    currentUser.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${currentUser.name}!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Ready to make a difference?',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Report Issue',
                  leadingIcon: Icons.report_problem,
                  onPressed: () => Get.to(() => ReportIssueView()),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'My Issues',
                  leadingIcon: Icons.list_alt,
                  onPressed: () => Get.toNamed(Routes.MY_ISSUES),
                  type: AppButtonType.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Users (${allUsers.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _showAllUsersDialog(context),
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                return _buildUserCard(context, user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => Get.to(() => UserProfileView(user: user)),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: _getUserTypeColor(user.userType),
              child: Text(
                user.name[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              user.name.split(' ')[0],
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Text(
              _getUserTypeShort(user.userType),
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentIssuesSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Issues',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.MY_ISSUES),
                child: Text('View All'),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (recentIssues.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No issues reported yet'),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recentIssues.length,
              itemBuilder: (context, index) {
                final issue = recentIssues[index];
                return _buildIssueCard(context, issue);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(BuildContext context, IssueModel issue) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  issue.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              StatusBadge(status: issue.status),
            ],
          ),
          SizedBox(height: 8),
          Text(
            issue.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  issue.address,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat('MMM dd').format(issue.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAllUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Users',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: allUsers.length,
                  itemBuilder: (context, index) {
                    final user = allUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getUserTypeColor(user.userType),
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.name),
                      subtitle: Text(
                        '${user.email} • ${_getUserTypeLabel(user.userType)}',
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => UserProfileView(user: user));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return Colors.blue;
      case 'citizen':
        return Colors.green;
      case 'worker':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getUserTypeShort(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return 'Gov';
      case 'citizen':
        return 'Cit';
      case 'worker':
        return 'Wkr';
      default:
        return userType;
    }
  }

  String _getUserTypeLabel(String userType) {
    switch (userType.toLowerCase()) {
      case 'admin':
        return 'Government Official';
      case 'citizen':
        return 'Citizen';
      case 'worker':
        return 'Municipal Worker';
      default:
        return userType;
    }
  }
}
