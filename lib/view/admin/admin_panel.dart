import 'package:cu_events/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/view/admin/admin_Panel/add_events.dart';
import 'package:cu_events/view/admin/admin_Panel/delete_events.dart';
import 'package:cu_events/view/admin/admin_Panel/update_events/update_events_tab.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // ignore: unused_field
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/secret-admin-login');
      });
    } else {
      const allowedEmail = 'cu.events.18@gmail.com';
      if (user.email == allowedEmail) {
        setState(() {
          _currentUser = user;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/home');
        });
        SchedulerBinding.instance.addPostFrameCallback((_) {
          showCustomSnackBar(context, "You are not ADMIN.");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Add',
            ),
            Tab(text: 'Update'),
            Tab(text: 'Delete'),
          ],
          labelStyle: Theme.of(context).textTheme.bodySmall,
          unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Add Events Tab
          AddEventsPanel(),
          // Modify Events Tab
          UpdateEventsTab(),
          // Delete Events Tab
          DeleteEventsPage()
        ],
      ),
    );
  }
}
