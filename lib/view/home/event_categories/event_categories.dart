import 'package:cu_events/constants.dart';
import 'package:flutter/material.dart';

//Create Statefull Class named ExpansionTileRadio
class ExpansionTileRadio extends StatefulWidget {
  const ExpansionTileRadio({Key? key}) : super(key: key);

  @override
  State<ExpansionTileRadio> createState() => _ExpansionTileRadioState();
}

class _ExpansionTileRadioState extends State<ExpansionTileRadio> {
  UniqueKey item1Key = UniqueKey();
  UniqueKey item2Key = UniqueKey();
  UniqueKey item3Key = UniqueKey();
  UniqueKey item4Key = UniqueKey();
  UniqueKey item5Key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            // First
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: primaryBckgnd,
                ),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  textColor: primaryBckgnd,
                  key: item1Key,
                  onExpansionChanged: (expanded) {
                    if (expanded == true) {
                      setState(() {
                        item2Key = UniqueKey();
                        item3Key = UniqueKey();
                        item4Key = UniqueKey();
                        item5Key = UniqueKey();
                      });
                    }
                  },
                  // rest of the basic code
                  title: const Text("Engineering"),
                  children: [
                    ListTile(
                      title: const Text('Academic Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/engineering/academic');
                      },
                    ),
                    ListTile(
                      title: const Text('Cultural Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/engineering/cultural');
                      },
                    ),
                    ListTile(
                      title: const Text('NSS/NCC'),
                      onTap: () {
                        Navigator.pushNamed(context, '/engineering/nss_ncc');
                      },
                    ),
                    ListTile(
                      title: const Text('Others'),
                      onTap: () {
                        Navigator.pushNamed(context, '/engineering/others');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Second
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: primaryBckgnd,
                ),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  textColor: primaryBckgnd,
                  key: item2Key, // Unique Key we initialise in starting
                  onExpansionChanged: (expanded) {
                    if (expanded == true) {
                      setState(() {
                        item1Key = UniqueKey();
                        item3Key = UniqueKey();
                        item4Key = UniqueKey();
                        item5Key = UniqueKey();
                      });
                    }
                  },
                  title: const Text("Medical"),
                  children: [
                    ListTile(
                      title: const Text('Academic Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/medical/academic');
                      },
                    ),
                    ListTile(
                      title: const Text('Cultural Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/medical/cultural');
                      },
                    ),
                    ListTile(
                      title: const Text('NSS/NCC'),
                      onTap: () {
                        Navigator.pushNamed(context, '/medical/nss_ncc');
                      },
                    ),
                    ListTile(
                      title: const Text('Others'),
                      onTap: () {
                        Navigator.pushNamed(context, '/medical/others');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Third
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: primaryBckgnd,
                ),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  textColor: primaryBckgnd,
                  key: item3Key, // Unique Key we initialise in starting
                  onExpansionChanged: (expanded) {
                    if (expanded == true) {
                      setState(() {
                        item1Key = UniqueKey();
                        item2Key = UniqueKey();
                        item4Key = UniqueKey();
                        item5Key = UniqueKey();
                      });
                    }
                  },
                  title: const Text("Business"),
                  children: [
                    ListTile(
                      title: const Text('Academic Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/business/academic');
                      },
                    ),
                    ListTile(
                      title: const Text('Cultural Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/business/cultural');
                      },
                    ),
                    ListTile(
                      title: const Text('NSS/NCC'),
                      onTap: () {
                        Navigator.pushNamed(context, '/business/nss_ncc');
                      },
                    ),
                    ListTile(
                      title: const Text('Others'),
                      onTap: () {
                        Navigator.pushNamed(context, '/business/others');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Fourth
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: primaryBckgnd,
                ),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  textColor: primaryBckgnd,
                  key: item4Key,
                  onExpansionChanged: (expanded) {
                    if (expanded == true) {
                      setState(() {
                        item1Key = UniqueKey();
                        item2Key = UniqueKey();
                        item3Key = UniqueKey();
                        item5Key = UniqueKey();
                      });
                    }
                  },
                  // rest of the basic code
                  title: const Text("Law"),
                  children: [
                    ListTile(
                      title: const Text('Academic Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/law/academic');
                      },
                    ),
                    ListTile(
                      title: const Text('Cultural Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/law/cultural');
                      },
                    ),
                    ListTile(
                      title: const Text('NSS/NCC'),
                      onTap: () {
                        Navigator.pushNamed(context, '/law/nss_ncc');
                      },
                    ),
                    ListTile(
                      title: const Text('Others'),
                      onTap: () {
                        Navigator.pushNamed(context, '/law/others');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // Fifth
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: primaryBckgnd,
                ),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  textColor: primaryBckgnd,
                  key: item5Key,
                  onExpansionChanged: (expanded) {
                    if (expanded == true) {
                      setState(() {
                        item1Key = UniqueKey();
                        item2Key = UniqueKey();
                        item3Key = UniqueKey();
                        item4Key = UniqueKey();
                      });
                    }
                  },
                  // rest of the basic code
                  title: const Text("Others"),
                  children: [
                    ListTile(
                      title: const Text('Academic Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/other/academic');
                      },
                    ),
                    ListTile(
                      title: const Text('Cultural Events'),
                      onTap: () {
                        Navigator.pushNamed(context, '/other/cultural');
                      },
                    ),
                    ListTile(
                      title: const Text('NSS/NCC'),
                      onTap: () {
                        Navigator.pushNamed(context, '/other/nss_ncc');
                      },
                    ),
                    ListTile(
                      title: const Text('Others'),
                      onTap: () {
                        Navigator.pushNamed(context, '/other/others');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
