import 'package:flutter/material.dart';
import 'package:cu_events/constants.dart';

class Category {
  final String name;
  final List<Subcategory> subcategories;

  Category({required this.name, required this.subcategories});
}

class Subcategory {
  final String name;
  final String route;

  Subcategory({required this.name, required this.route});
}

final List<Category> categories = [
  Category(
    name: 'Engineering',
    subcategories: [
      Subcategory(name: 'Academic Events', route: '/engineering/academic'),
      Subcategory(name: 'Cultural Events', route: '/engineering/cultural'),
      Subcategory(name: 'NSS/NCC', route: '/engineering/nss_ncc'),
      Subcategory(name: 'Others', route: '/engineering/others'),
    ],
  ),
  Category(
    name: 'Medical',
    subcategories: [
      Subcategory(name: 'Academic Events', route: '/medical/academic'),
      Subcategory(name: 'Cultural Events', route: '/medical/cultural'),
      Subcategory(name: 'NSS/NCC', route: '/medical/nss_ncc'),
      Subcategory(name: 'Others', route: '/medical/others'),
    ],
  ),
  Category(
    name: 'Business',
    subcategories: [
      Subcategory(name: 'Academic Events', route: '/business/academic'),
      Subcategory(name: 'Cultural Events', route: '/business/cultural'),
      Subcategory(name: 'NSS/NCC', route: '/business/nss_ncc'),
      Subcategory(name: 'Others', route: '/business/others'),
    ],
  ),
  Category(
    name: 'Law',
    subcategories: [
      Subcategory(name: 'Academic Events', route: '/law/academic'),
      Subcategory(name: 'Cultural Events', route: '/law/cultural'),
      Subcategory(name: 'NSS/NCC', route: '/law/nss_ncc'),
      Subcategory(name: 'Others', route: '/law/others'),
    ],
  ),
  Category(
    name: 'Others',
    subcategories: [
      Subcategory(name: 'Academic Events', route: '/other/academic'),
      Subcategory(name: 'Cultural Events', route: '/other/cultural'),
      Subcategory(name: 'NSS/NCC', route: '/other/nss_ncc'),
      Subcategory(name: 'Others', route: '/other/others'),
    ],
  ),
];

class CategoryExpansionTile extends StatefulWidget {
  const CategoryExpansionTile({super.key});

  @override
  _CategoryExpansionTileState createState() => _CategoryExpansionTileState();
}

class _CategoryExpansionTileState extends State<CategoryExpansionTile> {
  late final List<Item> _items = generateItems(categories);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        elevation: 0,
        children: _items.map<ExpansionPanelRadio>((Item item) {
          return ExpansionPanelRadio(
            value: item.id,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  item.category.name,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: isExpanded ? primaryBckgnd : textColor,
                      ),
                ),
              );
            },
            body: Column(
              children: item.category.subcategories.map((subcategory) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, subcategory.route);
                  },
                  child: ListTile(
                    title: Text(
                      subcategory.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Item> generateItems(List<Category> categories) {
    return List<Item>.generate(categories.length, (int index) {
      return Item(
        id: index,
        category: categories[index],
      );
    });
  }
}

class Item {
  Item({
    required this.id,
    required this.category,
  });

  int id;
  Category category;
}
