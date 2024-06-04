import 'package:cu_events/view/admin/admin_Panel/add_events.dart';
import 'package:cu_events/view/admin/admin_Panel/delete_events.dart';
import 'package:cu_events/view/admin/admin_Panel/update_events/update_events_tab.dart';
import 'package:flutter/material.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
