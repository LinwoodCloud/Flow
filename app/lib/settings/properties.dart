import 'package:flow_app/widgets/drawer.dart';
import 'package:flow_app/widgets/server.dart';
import 'package:flutter/material.dart';

class PropertiesSettingsPage extends StatefulWidget {
  @override
  _PropertiesSettingsPageState createState() => _PropertiesSettingsPageState();
}

class _PropertiesSettingsPageState extends State<PropertiesSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
        pageTitle: "Properties",
        page: RoutePages.properties,
        body: ServerView(
            builder: (server) => Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Column(children: [
                      TextField(decoration: InputDecoration(labelText: "Name")),
                      TextField(
                        decoration: InputDecoration(labelText: "Description"),
                        minLines: 3,
                        maxLines: null,
                      ),
                      SizedBox(height: 50),
                      Text("Features", style: Theme.of(context).textTheme.headline6),
                      SizedBox(height: 50),
                      CheckboxListTile(value: true, onChanged: (value) {}, title: Text("Teams")),
                      CheckboxListTile(value: true, onChanged: (value) {}, title: Text("Events")),
                      CheckboxListTile(value: false, onChanged: (value) {}, title: Text("Places")),
                      CheckboxListTile(
                          value: true, onChanged: (value) {}, title: Text("Dev-Doctor"))
                    ])))));
  }
}
