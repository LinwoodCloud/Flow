import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EventsAdminSettingsPage extends StatefulWidget {
  final String server;

  const EventsAdminSettingsPage({Key? key, required this.server}) : super(key: key);

  @override
  _EventsAdminSettingsPageState createState() => _EventsAdminSettingsPageState();
}

class _EventsAdminSettingsPageState extends State<EventsAdminSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
            constraints: BoxConstraints(maxWidth: 1000),
            padding: EdgeInsets.all(16.0),
            child: Column(children: [
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(PhosphorIcons.flagLight),
                  label: Text("OPEN PERMISSIONS"))
            ])));
  }
}