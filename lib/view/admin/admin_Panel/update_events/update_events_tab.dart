import 'package:cu_events/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_event_page.dart';

class UpdateEventsTab extends StatefulWidget {
  const UpdateEventsTab({Key? key}) : super(key: key);

  @override
  _UpdateEventsTabState createState() => _UpdateEventsTabState();
}

class _UpdateEventsTabState extends State<UpdateEventsTab> {
  late List<DocumentSnapshot> _events = [];
  List<DocumentSnapshot> _filteredEvents = [];
  final TextEditingController _searchController = TextEditingController();

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
    setState(() {
      _events = querySnapshot.docs;
      _filteredEvents = _events;
    });
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredEvents = _events;
      } else {
        _filteredEvents = _events
            .where((event) =>
                event['title'].toString().toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Events List ',
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: primaryBckgnd),
                        ),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = _filteredEvents[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              title: Text(event['title'] ?? ''),
                              onTap: () {
                                _navigateToEventDetails(event);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                ),
          ],
        ),
      ),
    );
  }

  void _navigateToEventDetails(DocumentSnapshot event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateEventPage(
          event: event,
          onUpdate: () {
            _fetchEvents(); // Refresh events after update
          },
        ),
      ),
    );
  }
}
