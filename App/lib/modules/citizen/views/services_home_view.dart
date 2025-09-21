import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/routes/app_routes.dart';
import 'package:jan_mitra/data/services/firebase_auth_service.dart';
import 'package:jan_mitra/modules/citizen/views/my_issues_view.dart';
import 'package:jan_mitra/modules/citizen/views/user_profile_view.dart';
import 'package:jan_mitra/core/ui/custom_app_bar.dart';
import 'package:jan_mitra/core/ui/app_card.dart';
import 'package:jan_mitra/core/ui/app_loading.dart';
import 'package:jan_mitra/core/theme/app_theme.dart';

class ServicesHomeView extends StatefulWidget {
  const ServicesHomeView({super.key});

  @override
  State<ServicesHomeView> createState() => _ServicesHomeViewState();
}

class _ServicesHomeViewState extends State<ServicesHomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Check if Firebase is available and authentication is required
    bool firebaseInitialized = false;
    try {
      firebaseInitialized = Get.find<bool>(tag: 'firebaseInitialized') ?? false;
    } catch (e) {
      // Firebase initialization status not available yet, assume false
      firebaseInitialized = false;
    }

    if (firebaseInitialized) {
      final authService = Get.find<FirebaseAuthService>();
      if (!authService.isAuthenticated.value ||
          authService.getCurrentUser() == null) {
        // Redirect to login if Firebase is available but user is not authenticated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(Routes.LOGIN);
        });
        return const Scaffold(
          body: Center(
            child: AppLoading(message: 'Checking authentication...'),
          ),
        );
      }
    }
    // If Firebase is not available, allow the app to work without authentication

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: 'Jan Mitra',
        onRefreshTap: () {
          Get.snackbar(
            'Refreshing',
            'Data refreshed successfully!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.primaryColor,
            colorText: Colors.white,
          );
        },
        onProfileTap: () {
          setState(() {
            _currentIndex = 2;
          });
        },
        onNotificationTap: () {
          Get.snackbar(
            'Notifications',
            'You have 3 new notifications',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppTheme.primaryColor,
            colorText: Colors.white,
          );
        },
        showNotificationBadge: true,
        notificationCount: 3,
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Services'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Issues',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return _buildServicesContent(context);
      case 1:
        return MyIssuesView();
      case 2:
        try {
          bool firebaseInitialized = false;
          try {
            firebaseInitialized =
                Get.find<bool>(tag: 'firebaseInitialized') ?? false;
          } catch (e) {
            // Firebase initialization status not available yet, assume false
            firebaseInitialized = false;
          }

          if (firebaseInitialized) {
            final authService = Get.find<FirebaseAuthService>();
            final currentUser = authService.getCurrentUser();
            if (currentUser != null) {
              return UserProfileView(user: currentUser);
            }
          }

          // If Firebase is not available or user is not authenticated, show demo profile
          return _buildDemoProfile(context);
        } catch (e) {
          return _buildErrorView(context, 'Unable to access profile: $e');
        }
      default:
        return _buildServicesContent(context);
    }
  }

  Widget _buildServicesContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and location icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Services on Request',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.location_on, color: Colors.black, size: 24),
              ],
            ),
            const SizedBox(height: 40),

            // Service Cards
            Center(
              child: _buildServiceCard(
                context: context,
                icon: Icons.local_shipping,
                title: 'Garbage Collection',
                subtitle: 'Request garbage collection service',
                onTap: () => _navigateToIssueForm('garbage_collection'),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: _buildServiceCard(
                context: context,
                icon: Icons.report_problem,
                title: 'Raise Complaint',
                subtitle: 'Report civic issues and complaints',
                onTap: () => _navigateToIssueForm('complaint'),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: _buildServiceCard(
                context: context,
                icon: Icons.pets,
                title: 'Animal',
                subtitle: 'Report animal-related issues reports',
                onTap: () => _navigateToIssueForm('animal'),
              ),
            ),

            const SizedBox(height: 32),

            // Bottom section with additional info
            // InfoCard(
            //   title: 'How it works',
            //   message:
            //       'Select a service to report an issue or request assistance',
            //   icon: Icons.info_outline_rounded,
            //   color: AppTheme.primaryColor,
            // ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return AppEmptyWidget(
      title: 'Please Login',
      message: 'You need to be logged in to view your profile',
      icon: Icons.person_outline_rounded,
      actionText: 'Go to Login',
      onAction: () => Get.toNamed(Routes.LOGIN),
    );
  }

  Widget _buildDemoProfile(BuildContext context) {
    return AppEmptyWidget(
      title: 'Demo Mode',
      message:
          'Authentication is not available. You can still report issues and view them.',
      icon: Icons.info_outline_rounded,
      actionText: 'Continue',
      onAction: () => Get.snackbar(
        'Demo Mode',
        'You are using the app in demo mode without authentication',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.primaryColor,
        colorText: Colors.white,
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return AppErrorWidget(
      title: 'Error',
      message: error,
      icon: Icons.error_outline_rounded,
      onRetry: () {
        setState(() {
          _currentIndex = 0;
        });
      },
      retryText: 'Go Back',
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ServiceCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  void _navigateToIssueForm(String serviceType) {
    Get.toNamed(
      Routes.SERVICE_ISSUE_FORM,
      arguments: {'serviceType': serviceType},
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.location_city, size: 40, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Jan Mitra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Civic Issue Reporting System',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Services Home'),
            selected: _currentIndex == 0,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('My Issues'),
            selected: _currentIndex == 1,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Issue Tracker'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(Routes.ISSUE_TRACKER);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            selected: _currentIndex == 2,
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 2;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Info', 'Settings coming soon!');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Info', 'Help & Support coming soon!');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Get.snackbar('Info', 'Jan Mitra v1.0.0');
            },
          ),
        ],
      ),
    );
  }
}
