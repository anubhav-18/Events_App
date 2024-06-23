// Hackathon(
//       name: 'Infothon 3.0',
//       organizer: 'Vidyavardhaka College of Engineering, Mysore',
//       prize: '60,000',
//       status: 'Launching soon',
//       daysLeft: 8,
//       categories: ['Hackathon', 'All'],
//     ),
//     Hackathon(
//       name: 'DevX JMI',
//       organizer: 'Jamia Millia Islamia',
//       registered: 24,
//       daysLeft: 8,
//       categories: ['Engineering Students', 'MBA Students'],
//     ),
//     Hackathon(
//       name: 'F1nalyze - Formula 1 Datathon',
//       organizer: 'IEEE Computer Society MUJ',
//       prize: '10,000',
//       registered: 136,
//       daysLeft: 5,
//       categories: ['All', 'Coding Challenge'],
//     ),
//     Hackathon(
//       name: 'Idea Ignite',
//       organizer: 'CODEBYTE',
//       registered: 703,
//       daysLeft: 5,
//     ),
//   ];

import 'package:cu_events/src/UI/btm_nav_section/hackathon/filter_hackathon.dart';
import 'package:cu_events/src/UI/btm_nav_section/hackathon/hackathon_card.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/hackathon_model.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:flutter/material.dart';

class HackathonsPage extends StatefulWidget {
  const HackathonsPage({super.key});

  @override
  _HackathonsPageState createState() => _HackathonsPageState();
}

class _HackathonsPageState extends State<HackathonsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedCategory;
  String? _selectedSortBy;
  String? _searchQuery;
  bool _liveOnly = false;
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search Hackathons',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      hint: const Text('Categories'),
                      items: ['Hackathons', 'All'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedSortBy,
                      hint: const Text('Sort By'),
                      items: ['Date', 'Popularity'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSortBy = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // Filter button functionality
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return FilterBottomSheet(
                            liveOnly: _liveOnly,
                            selectedStatus: _selectedStatus,
                            onLiveOnlyChanged: (value) {
                              setState(() {
                                _liveOnly = value;
                              });
                            },
                            onStatusChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                          );
                        },
                      );
                    },
                    child: const Text('Filters'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Hackathon>>(
                stream: _firestoreService
                    .getHackathons(), // Stream from Firestore service
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
      
                  List<Hackathon> filteredHackathons = snapshot.data!
                      .where((hackathon) => _filterHackathon(hackathon))
                      .toList();
      
                  // Apply sorting
                  if (_selectedSortBy == 'Date') {
                    filteredHackathons.sort((a, b) => a.daysLeft!.compareTo(
                        b.daysLeft!)); // Adjust sorting logic as needed
                  } else if (_selectedSortBy == 'Popularity') {
                    // Implement popularity sorting logic if needed
                  }
      
                  return ListView.builder(
                    itemCount: filteredHackathons.length,
                    itemBuilder: (context, index) {
                      return HackathonCard(hackathon: filteredHackathons[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _filterHackathon(Hackathon hackathon) {
    if (_searchQuery != null &&
        !hackathon.name.toLowerCase().contains(_searchQuery!.toLowerCase())) {
      return false;
    }
    if (_selectedCategory != null &&
        !hackathon.categories!.contains(_selectedCategory!)) {
      return false;
    }
    if (_liveOnly && hackathon.status != 'Live') {
      return false;
    }
    if (_selectedStatus != null && hackathon.status != _selectedStatus) {
      return false;
    }
    return true;
  }
}
