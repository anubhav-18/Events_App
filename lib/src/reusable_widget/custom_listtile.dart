import 'package:cu_events/src/constants.dart';
import 'package:flutter/material.dart';

class CustomListTileGroup extends StatelessWidget {
  final String? header;
  final List<ListTile> tiles; // List of ListTile widgets

  const CustomListTileGroup({
    Key? key,
    this.header,
    required this.tiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) 
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                color: whiteColor,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    color: primaryBckgnd,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    header!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBckgnd,
                    ),
                  ),
                ],
              ),
            ),

          // List of Tiles
          ClipRRect(
            // Apply rounded corners to the ListTile group
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
            child: Column(
              children: tiles
                  .map((tile) => Theme(
                        // Apply this theme to each ListTile
                        data: Theme.of(context).copyWith(
                          dividerColor:
                              Colors.transparent, // Remove default divider
                        ),
                        child: ListTile(
                          tileColor: whiteColor,
                          shape: RoundedRectangleBorder(
                            // Round the corners of individual tiles
                            borderRadius: BorderRadius.vertical(
                              bottom: tile == tiles.last
                                  ? const Radius.circular(10.0)
                                  : Radius
                                      .zero, // Only round bottom corners of the last tile
                            ),
                          ),
                          leading: tile.leading,
                          onTap: tile.onTap,
                          trailing: tile.trailing,
                          title: tile.title,
                          // ... (rest of your ListTile code)'
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
