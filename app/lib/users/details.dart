import 'package:flow_app/services/api_service.dart';
import 'package:flow_app/services/local_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared/user.dart';

class UserPage extends StatefulWidget {
  final User? user;
  final int? id;
  final bool isDesktop;

  const UserPage({Key? key, this.user, this.id, this.isDesktop = false}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _displayNameController = TextEditingController();
  late TextEditingController _bioController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late ApiService service;

  @override
  void initState() {
    super.initState();
    service = GetIt.I.get<LocalService>();
  }

  @override
  void didUpdateWidget(UserPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    service = GetIt.I.get<LocalService>();
  }

  String? server = "";
  @override
  Widget build(BuildContext context) {
    return widget.id == null
        ? _buildView(null)
        : StreamBuilder<User?>(
            stream: service.onUser(widget.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("Error ${snapshot.error}");
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return _buildView(snapshot.data);
            });
  }

  Widget _buildView(User? user) {
    var create = user == null;
    _nameController.text = user?.name ?? "";
    _bioController.text = user?.bio ?? "";
    _displayNameController.text = user?.displayName ?? "";
    _emailController.text = user?.email ?? "";
    var userState = user?.state ?? UserState.fake;
    return Scaffold(
        appBar: AppBar(title: Text(create ? "Create user" : user!.name)),
        floatingActionButton: FloatingActionButton(
            heroTag: "user-check",
            child: Icon(PhosphorIcons.checkLight),
            onPressed: () {
              if (create) {
                service.createUser(User(_nameController.text,
                    bio: _bioController.text,
                    displayName: _displayNameController.text,
                    email: _emailController.text));
                if (widget.isDesktop) {
                  _nameController.text = "";
                  _bioController.text = "";
                  _displayNameController.text = "";
                  _emailController.text = "";
                }
              } else
                service.updateUser(user!.copyWith(
                    name: _nameController.text,
                    bio: _bioController.text,
                    displayName: _displayNameController.text,
                    email: _emailController.text));
              if (Modular.to.canPop() && !widget.isDesktop) Modular.to.pop();
            }),
        body: Column(children: [
          if (widget.isDesktop)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                  onPressed: () => Modular.to.pushNamed(widget.id == null
                      ? "/users/create"
                      : Uri(
                          pathSegments: ["", "users", "details"],
                          queryParameters: {"id": widget.id.toString()}).toString()),
                  icon: Icon(PhosphorIcons.arrowSquareOutLight),
                  label: Text("OPEN IN NEW WINDOW")),
            ),
          Expanded(
              child: SingleChildScrollView(
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          constraints: BoxConstraints(maxWidth: 800),
                          child: Column(children: [
                            SizedBox(height: 50),
                            DropdownButtonFormField<String>(
                                value: server,
                                decoration: InputDecoration(
                                    labelText: "Server", border: OutlineInputBorder()),
                                onChanged: (value) => setState(() => server = value),
                                items: [
                                  ...Hive.box<String>('servers')
                                      .values
                                      .map((e) => DropdownMenuItem(child: Text(e), value: e)),
                                  DropdownMenuItem(child: Text("Local"), value: "")
                                ]),
                            SizedBox(height: 50),
                            TextField(
                                decoration: InputDecoration(
                                    labelText: "Name", icon: Icon(PhosphorIcons.userLight)),
                                controller: _nameController),
                            TextField(
                                decoration: InputDecoration(
                                    labelText: "Display name",
                                    icon: Icon(PhosphorIcons.identificationCardLight)),
                                controller: _displayNameController),
                            TextField(
                                decoration: InputDecoration(
                                    labelText: "Email", icon: Icon(PhosphorIcons.envelopeLight)),
                                controller: _emailController),
                            TextField(
                                decoration: InputDecoration(
                                    labelText: "Biography", icon: Icon(PhosphorIcons.articleLight)),
                                maxLines: null,
                                controller: _bioController,
                                minLines: 3),
                            if (user != null) ...[
                              SizedBox(height: 10),
                              PopupMenuButton<UserState>(
                                  initialValue: userState,
                                  onSelected: (value) =>
                                      service.updateUser(user.copyWith(state: value)),
                                  itemBuilder: (context) => UserState.values
                                      .map(
                                          (e) => PopupMenuItem(child: Text(e.toString()), value: e))
                                      .toList(),
                                  child: ListTile(
                                      title: Text("User state"),
                                      subtitle: Text(userState.toString()))),
                              SizedBox(height: 50),
                              ElevatedButton.icon(
                                  icon: Icon(PhosphorIcons.lockLight),
                                  label: Text("CHANGE PASSWORD"),
                                  onPressed: () {})
                            ]
                          ])))))
        ]));
  }
}