import 'package:flow_app/widgets/scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

enum RoutePages { home, teams, events, general, servers, appearance, roles, properties }

class FlowDrawer extends StatelessWidget {
  final RoutePages? page;
  final bool admin;
  final bool permanentlyDisplay;

  const FlowDrawer({Key? key, this.page, this.admin = false, this.permanentlyDisplay = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        right: false,
        child: Drawer(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Column(children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "images/icon.png",
                      height: 128,
                    ),
                  ),
                  Text("Linwood Flow", style: Theme.of(context).textTheme.headline5),
                ])),
            Divider(),
            ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text("Home"),
                onTap: () => Modular.to.pushReplacementNamed("/"),
                selected: page == RoutePages.home),
            ListTile(
                leading: const Icon(Icons.people_outline_outlined),
                title: const Text("Teams"),
                onTap: () => Modular.to.pushReplacementNamed("/teams"),
                selected: page == RoutePages.teams),
            ListTile(
                leading: const Icon(Icons.event_outlined),
                title: const Text("Events"),
                onTap: () => Modular.to.pushReplacementNamed("/events"),
                selected: page == RoutePages.events),
            ExpansionTile(title: Text('Settings'), initiallyExpanded: true, children: <Widget>[
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        ListTile(
                            leading: const Icon(Icons.build_outlined),
                            title: const Text("General"),
                            onTap: () => Modular.to.pushReplacementNamed("/settings"),
                            selected: page == RoutePages.general),
                        ListTile(
                            leading: const Icon(Icons.format_list_bulleted_outlined),
                            title: const Text("Servers"),
                            onTap: () => Modular.to.pushReplacementNamed("/settings/servers"),
                            selected: page == RoutePages.servers),
                        ListTile(
                            leading: const Icon(Icons.tune_outlined),
                            title: const Text("Appearance"),
                            onTap: () => Modular.to.pushReplacementNamed("/settings/appearance"),
                            selected: page == RoutePages.appearance),
                        ListTile(
                            leading: const Icon(Icons.group_outlined),
                            title: const Text("Roles"),
                            onTap: () => Modular.to.pushReplacementNamed("/settings/roles"),
                            selected: page == RoutePages.roles),
                        ListTile(
                            leading: const Icon(Icons.settings_outlined),
                            title: const Text("Properties"),
                            onTap: () => Modular.to.pushReplacementNamed("/settings/properties"),
                            selected: page == RoutePages.properties)
                      ])))
            ])
          ]))),
          if (permanentlyDisplay) const VerticalDivider(width: 5, thickness: 0.5)
        ])));
  }
}

class FlowScaffold extends ResponsiveScaffold {
  FlowScaffold(
      {List<Widget> actions = const [],
      required Widget body,
      RoutePages? page,
      FloatingActionButton? floatingActionButton,
      PreferredSizeWidget? bottom,
      String pageTitle = '',
      Key? key})
      : super(
            actions: actions,
            pageTitle: pageTitle,
            bottom: bottom,
            body: body,
            drawer: FlowDrawer(page: page, permanentlyDisplay: false),
            desktopDrawer: FlowDrawer(page: page, permanentlyDisplay: true),
            floatingActionButton: floatingActionButton,
            key: key);
}
