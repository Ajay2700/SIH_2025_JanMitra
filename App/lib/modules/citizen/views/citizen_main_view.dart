import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jan_mitra/modules/citizen/controllers/citizen_main_controller.dart';
import 'package:jan_mitra/modules/citizen/views/citizen_home_view.dart';
import 'package:jan_mitra/modules/citizen/views/my_issues_view.dart';
import 'package:jan_mitra/modules/citizen/views/profile_view.dart';
import 'package:jan_mitra/modules/citizen/views/report_issue_view.dart';

class CitizenMainView extends StatelessWidget {
  final CitizenMainController _controller = Get.find<CitizenMainController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (_controller.currentIndex.value) {
          case 0:
            return CitizenHomeView();
          case 1:
            return MyIssuesView();
          case 2:
            return ReportIssueView();
          case 3:
            return ProfileView();
          default:
            return CitizenHomeView();
        }
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: _controller.currentIndex.value,
          onTap: _controller.changePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'My Issues',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Report',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      }),
    );
  }
}
