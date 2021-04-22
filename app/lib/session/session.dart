import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SessionPage extends StatefulWidget {
  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    var registerRoute = Modular.to.path.startsWith("/session/register");
    return DefaultTabController(
        length: 2,
        initialIndex: registerRoute ? 1 : 0,
        child: Scaffold(
            appBar: AppBar(
                title: Text("Session"),
                bottom: TabBar(
                    onTap: (index) async {
                      Modular.to.navigate(index == 0 ? "/session/login" : "/session/register");
                      setState(() {});
                    },
                    tabs: [
                      Tab(icon: Icon(Icons.login_outlined)),
                      Tab(icon: Icon(Icons.person_add_outlined))
                    ])),
            body: RouterOutlet()));
  }
}