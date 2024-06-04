import 'package:cu_events/constants.dart';
import 'package:cu_events/reusable_widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DeleteEventsPage extends StatefulWidget {
  const DeleteEventsPage({Key? key}) : super(key: key);

  @override
  _DeleteEventsPageState createState() => _DeleteEventsPageState();
}

class _DeleteEventsPageState extends State<DeleteEventsPage> {
  late List<DocumentSnapshot> _events = [];
  List<DocumentSnapshot> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _searchController.addListener(_filterEvents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();
    if (mounted) {
      setState(() {
        _events = querySnapshot.docs;
        _filteredEvents = _events;
      });
    }
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    if (mounted) {
      setState(() {
        if (query.isEmpty && _selectedDeadline == null) {
          _filteredEvents = _events;
        } else {
          _filteredEvents = _events.where((event) {
            final matchesQuery =
                event['title'].toString().toLowerCase().contains(query);
            final matchesDeadline = _selectedDeadline == null ||
                (event['deadline'] != null &&
                    (event['deadline'] as Timestamp)
                        .toDate()
                        .isBefore(_selectedDeadline!));
            return matchesQuery && matchesDeadline;
          }).toList();
        }
      });
    }
  }

  void _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event deleted successfully'),
        ),
      );
      _fetchEvents(); // Refresh events after deletion
    } catch (e) {
      print('Failed to delete event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete event'),
        ),
      );
    }
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (selectedDate != null && mounted) {
      setState(() {
        _selectedDeadline = selectedDate;
        _filterEvents();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedDeadline = null;
      _filterEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor: whiteColor,
                  filled: true,
                  hintText: 'Search Events',
                  hintStyle: const TextStyle(color: textColor),
                  contentPadding: const EdgeInsets.all(0),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: primaryBckgnd,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearFilters,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: primaryBckgnd),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              elevatedButton(
                  context,
                  () => _selectDeadline(context),
                  _selectedDeadline == null
                      ? 'Select Deadline'
                      : DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
                  MediaQuery.of(context).size.width * 0.45),
              const SizedBox(height: 10),
              _filteredEvents.isEmpty
                  ? Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No events found',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        return ListTile(
                          title: Text(event['title'] ?? ''),
                          subtitle: Text(
                            event['deadline'] != null
                                ? 'Deadline: ${DateFormat('yyyy-MM-dd').format((event['deadline'] as Timestamp).toDate())}'
                                : 'No Deadline',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Are you sure?',
                                    ),
                                    content: const Text(
                                      'Do you want to delete this event?',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No',),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteEvent(event.id);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Yes',),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
