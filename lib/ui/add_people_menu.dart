import 'package:flutter/material.dart';

import '../features/people/add_person_screen.dart';
import '../features/people/bulk_add_screen.dart';

/// One plus in the top right that opens both ways of adding people.
class AddPeopleMenu extends StatelessWidget {
  const AddPeopleMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      key: const Key('add-menu'),
      tooltip: 'Add people',
      icon: const Icon(Icons.add),
      onSelected: (v) {
        final screen = v == 0 ? const AddPersonScreen() : const BulkAddScreen();
        Navigator.of(context).push(MaterialPageRoute<Object?>(builder: (_) => screen));
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 0,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person_add_alt_1_outlined),
            title: Text('Add someone'),
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.contacts_outlined),
            title: Text('Add from contacts'),
          ),
        ),
      ],
    );
  }
}
