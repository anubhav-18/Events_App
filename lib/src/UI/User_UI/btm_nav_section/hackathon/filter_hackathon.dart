import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final bool liveOnly;
  final String? selectedStatus;
  final Function(bool) onLiveOnlyChanged;
  final Function(String?) onStatusChanged;

  const FilterBottomSheet({
    Key? key,
    required this.liveOnly,
    required this.selectedStatus,
    required this.onLiveOnlyChanged,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Checkbox(
                value: widget.liveOnly,
                onChanged: (value) {
                  widget.onLiveOnlyChanged(value!);
                },
              ),
              const Text('Live Only'),
            ],
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          RadioListTile<String>(
            title: const Text('Live'),
            value: 'Live',
            groupValue: widget.selectedStatus,
            onChanged: (value) {
              widget.onStatusChanged(value);
            },
          ),
          RadioListTile<String>(
            title: const Text('Expired'),
            value: 'Expired',
            groupValue: widget.selectedStatus,
            onChanged: (value) {
              widget.onStatusChanged(value);
            },
          ),
          RadioListTile<String>(
            title: const Text('Closed'),
            value: 'Closed',
            groupValue: widget.selectedStatus,
            onChanged: (value) {
              widget.onStatusChanged(value);
            },
          ),
          RadioListTile<String>(
            title: const Text('Recent'),
            value: 'Recent',
            groupValue: widget.selectedStatus,
            onChanged: (value) {
              widget.onStatusChanged(value);
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
