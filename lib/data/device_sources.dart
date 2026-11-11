import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Platform-specific inputs behind small interfaces, so iPhone support and
/// tests only swap these classes.

class PhoneContact {
  const PhoneContact({required this.id, required this.name, this.phone});
  final String id;
  final String name;
  final String? phone;
}

enum ContactsAccess { granted, denied, permanentlyDenied }

abstract class ContactsSource {
  /// Asks for permission. Called only when a bulk add starts.
  Future<ContactsAccess> requestAccess();

  /// Contacts that have a name, A to Z.
  Future<List<PhoneContact>> load();
}

class DeviceContactsSource implements ContactsSource {
  @override
  Future<ContactsAccess> requestAccess() async {
    final s = await FlutterContacts.permissions.request(PermissionType.read);
    if (s == PermissionStatus.granted || s == PermissionStatus.limited) {
      return ContactsAccess.granted;
    }
    return s == PermissionStatus.permanentlyDenied
        ? ContactsAccess.permanentlyDenied
        : ContactsAccess.denied;
  }

  @override
  Future<List<PhoneContact>> load() async {
    final all = await FlutterContacts.getAll(
        properties: {ContactProperty.name, ContactProperty.phone});
    final out = <PhoneContact>[];
    for (final c in all) {
      final name = (c.displayName ?? '').trim();
      if (name.isEmpty || c.id == null) continue;
      final phones = c.phones;
      final primary = phones.where((p) => p.isPrimary == true);
      final number = (primary.isNotEmpty ? primary.first : (phones.isEmpty ? null : phones.first))?.number;
      out.add(PhoneContact(id: c.id!, name: name, phone: number));
    }
    out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return out;
  }
}

abstract class DeviceTimezone {
  /// IANA name of this phone's timezone, e.g. Europe/Lisbon.
  Future<String> current();
}

class FlutterDeviceTimezone implements DeviceTimezone {
  @override
  Future<String> current() async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (_) {
      return 'UTC';
    }
  }
}
