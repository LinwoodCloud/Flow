import 'package:flow_app/services/api_service.dart';
import 'package:flow_app/services/local_service.dart';
import 'package:flow_app/widgets/assign_dialog.dart';
import 'package:flow_app/widgets/date.dart';
import 'package:flow_app/widgets/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared/event.dart';

class EventPage extends StatefulWidget {
  final int? id;
  final bool isDesktop, isDialog;

  const EventPage({Key? key, this.id, this.isDesktop = false, this.isDialog = false}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> with TickerProviderStateMixin {
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  late TabController _tabController;
  late ApiService service;

  @override
  void initState() {
    super.initState();
    service = GetIt.I.get<LocalService>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didUpdateWidget(EventPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    service = GetIt.I.get<LocalService>();
  }

  String? server = "";

  @override
  Widget build(BuildContext context) {
    return widget.id == null
        ? _buildView(null)
        : StreamBuilder<Event?>(
            stream: service.onEvent(widget.id!),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");
              if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return _buildView(snapshot.data);
            });
  }

  Widget _buildView(Event? event) {
    var create = event == null;
    bool isCanceled = event?.isCanceled ?? false;
    DateTime? startDateTime = event?.startDateTime, endDateTime = event?.endDateTime;
    _nameController.text = event?.name ?? "";
    _descriptionController.text = event?.description ?? "";
    return Scaffold(
        appBar: AppBar(
            leading: widget.isDialog
                ? IconButton(icon: Icon(PhosphorIcons.xLight), onPressed: () => Navigator.of(context).pop())
                : null,
            title: Text(create ? "Create event" : event!.name),
            actions: [
              if (widget.isDesktop)
                IconButton(
                    onPressed: () => Modular.to.pushNamed(widget.id == null
                        ? "/events/create"
                        : Uri(pathSegments: ["", "events", "details"], queryParameters: {"id": widget.id.toString()})
                            .toString()),
                    icon: Icon(PhosphorIcons.arrowSquareOutLight))
            ],
            bottom: TabBar(controller: _tabController, tabs: [
              Tab(icon: Icon(PhosphorIcons.wrenchLight), text: "General"),
              Tab(icon: Icon(PhosphorIcons.calendarLight), text: "Date and time")
            ])),
        floatingActionButton: FloatingActionButton(
            heroTag: "event-check",
            child: Icon(PhosphorIcons.checkLight),
            onPressed: () {
              if (create) {
                service.createEvent(Event(_nameController.text, description: _descriptionController.text));
                if (widget.isDesktop) {
                  _nameController.clear();
                  _descriptionController.clear();
                }
              } else
                service.updateEvent(event!.copyWith(
                    name: _nameController.text,
                    description: _descriptionController.text,
                    isCanceled: isCanceled,
                    startDateTime: startDateTime,
                    endDateTime: endDateTime,
                    removeStartDateTime: startDateTime == null,
                    removeEndDateTime: endDateTime == null));
              if (Modular.to.canPop() && !widget.isDesktop) Modular.to.pop();
            }),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TabBarView(controller: _tabController, children: [
            Column(children: [
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
                                    decoration: InputDecoration(labelText: "Server", border: OutlineInputBorder()),
                                    onChanged: (value) => setState(() => server = value),
                                    items: [
                                      ...Hive.box<String>('servers')
                                          .values
                                          .map((e) => DropdownMenuItem(child: Text(e), value: e)),
                                      DropdownMenuItem(child: Text("Local"), value: "")
                                    ]),
                                SizedBox(height: 50),
                                TextField(
                                    decoration:
                                        InputDecoration(labelText: "Name", icon: Icon(PhosphorIcons.calendarLight)),
                                    controller: _nameController),
                                TextField(
                                    decoration: InputDecoration(
                                        labelText: "Description", icon: Icon(PhosphorIcons.articleLight)),
                                    maxLines: null,
                                    controller: _descriptionController,
                                    minLines: 3),
                                if (event != null) ...[
                                  SizedBox(height: 20),
                                  ElevatedButton.icon(
                                      icon: Icon(PhosphorIcons.compassLight),
                                      label: Text("ASSIGN"),
                                      onPressed: () async {
                                        var assigned = await showDialog(
                                            context: context,
                                            builder: (context) => AssignDialog(assigned: event.assigned));
                                        if (assigned != null) service.updateEvent(event.copyWith(assigned: assigned));
                                      })
                                ]
                              ])))))
            ]),
            Column(children: [
              SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: DateInputField(
                        label: "Start date",
                        initialDate: startDateTime,
                        onChanged: (dateTime) => startDateTime = dateTime)),
                Expanded(
                    child: TimeInputField(
                        label: "Start time",
                        initialTime: startDateTime != null ? TimeOfDay.fromDateTime(startDateTime!) : null,
                        onChanged: (time) {
                          var oldDate = startDateTime ?? DateTime.now();
                          startDateTime =
                              DateTime(oldDate.year, oldDate.month, oldDate.day, time?.hour ?? 0, time?.minute ?? 0);
                        }))
              ]),
              SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: DateInputField(
                        label: "End date", initialDate: endDateTime, onChanged: (dateTime) => endDateTime = dateTime)),
                Expanded(
                    child: TimeInputField(
                        label: "End time",
                        initialTime: endDateTime != null ? TimeOfDay.fromDateTime(endDateTime!) : null,
                        onChanged: (time) {
                          var oldDate = endDateTime ?? DateTime.now();
                          endDateTime =
                              DateTime(oldDate.year, oldDate.month, oldDate.day, time?.hour ?? 0, time?.minute ?? 0);
                        }))
              ]),
              if (event != null) ...[
                SizedBox(height: 20),
                StatefulBuilder(builder: (context, setState) {
                  return CheckboxListTile(
                      value: isCanceled,
                      onChanged: (value) => setState(() => isCanceled = value ?? isCanceled),
                      title: Text("Canceled"),
                      subtitle: Text("Check if the event is canceled"),
                      controlAffinity: ListTileControlAffinity.leading);
                })
              ]
            ])
          ]),
        ));
  }
}
