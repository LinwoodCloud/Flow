import 'package:flow_app/services/api_service.dart';
import 'package:flow_app/services/local_service.dart';
import 'package:flow_app/widgets/assign_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared/task.dart';

class TaskPage extends StatefulWidget {
  final int? id;
  final bool isDesktop;

  const TaskPage({Key? key, this.id, this.isDesktop = false}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  late ApiService service;

  @override
  void initState() {
    super.initState();
    service = GetIt.I.get<LocalService>();
  }

  @override
  void didUpdateWidget(TaskPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    service = GetIt.I.get<LocalService>();
  }

  String? server = "";

  @override
  Widget build(BuildContext context) {
    return widget.id == null
        ? _buildView(null)
        : StreamBuilder<Task?>(
            stream: service.onTask(widget.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return _buildView(snapshot.data);
            });
  }

  Widget _buildView(Task? task) {
    var create = task == null;
    _nameController.text = task?.name ?? "";
    _descriptionController.text = task?.description ?? "";
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
                title: Text(create ? "Create task" : task!.name),
                actions: [
                  if (widget.isDesktop)
                    IconButton(
                        onPressed: () => Modular.to.pushNamed(widget.id == null
                            ? "/tasks/create"
                            : Uri(
                                pathSegments: ["", "tasks", "details"],
                                queryParameters: {"id": widget.id.toString()}).toString()),
                        icon: Icon(PhosphorIcons.arrowSquareOutLight))
                ],
                bottom: TabBar(tabs: [
                  Tab(icon: Icon(PhosphorIcons.wrenchLight), text: "General"),
                  Tab(icon: Icon(PhosphorIcons.foldersLight), text: "Submission")
                ])),
            floatingActionButton: FloatingActionButton(
                heroTag: "task-check",
                child: Icon(PhosphorIcons.checkLight),
                onPressed: () {
                  if (create) {
                    service.createTask(
                        Task(_nameController.text, description: _descriptionController.text));
                    if (widget.isDesktop) {
                      _nameController.clear();
                      _descriptionController.clear();
                    }
                  } else
                    service.updateTask(task!.copyWith(
                        name: _nameController.text, description: _descriptionController.text));
                  if (Modular.to.canPop() && !widget.isDesktop) Modular.to.pop();
                }),
            body: TabBarView(children: [
              SingleChildScrollView(
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
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
                                    filled: true,
                                    labelText: "Name",
                                    icon: Icon(PhosphorIcons.calendarLight)),
                                controller: _nameController),
                            SizedBox(height: 20),
                            TextField(
                                decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: "Description",
                                    icon: Icon(PhosphorIcons.articleLight)),
                                maxLines: null,
                                controller: _descriptionController,
                                minLines: 3),
                            if (task != null) ...[
                              SizedBox(height: 20),
                              ListTile(
                                  leading: Icon(PhosphorIcons.compassLight),
                                  title: Text("Assign"),
                                  onTap: () async {
                                    var assigned = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            AssignDialog(assigned: task.assigned));
                                    if (assigned != null)
                                      service.updateTask(task.copyWith(assigned: assigned));
                                  })
                            ]
                          ])))),
              Container(
                  child: ListView(children: [
                ExpansionTile(
                    title: Text("Admin"),
                    leading: Icon(PhosphorIcons.gearLight),
                    children: [
                      ListTile(
                          title: Text("Submission type"),
                          subtitle: Text("None"),
                          onTap: () {},
                          leading: Icon(PhosphorIcons.fileLight)),
                      ListTile(
                          title: Text("Show submissions"),
                          onTap: () {},
                          leading: Icon(PhosphorIcons.listLight))
                    ])
              ]))
            ])));
  }
}
