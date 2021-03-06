import 'package:flow/events/details.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared/models/event.dart';
import 'package:shared/services/api_service.dart';
import 'package:shared/services/local/service.dart';

class EventsOverviewView extends StatefulWidget {
  const EventsOverviewView({Key? key}) : super(key: key);

  @override
  _EventsOverviewViewState createState() => _EventsOverviewViewState();
}

class _EventsOverviewViewState extends State<EventsOverviewView> {
  int _selectedIndex = 1;
  late EventsApiService service;

  @override
  void initState() {
    super.initState();

    service = GetIt.I.get<LocalService>().events;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void openDialog(Event? event) => showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => Dialog(
          child: Container(
              constraints: const BoxConstraints(maxHeight: 750, maxWidth: 500),
              child: EventPage(isDesktop: true, id: event?.id))));

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      StreamBuilder<List<Event>>(
        stream: service.onOpenedEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Text("Error: ${snapshot.error}");
          var events = snapshot.data!;
          return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                return ListTile(
                  title: Text(event.name),
                  onTap: () => openDialog(event),
                );
              });
        },
      ),
      StreamBuilder<List<Event>>(
        stream: service.onPlannedEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Text("Error: ${snapshot.error}");
          var events = snapshot.data!;
          return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                return ListTile(
                  title: Text(event.name),
                  onTap: () => openDialog(event),
                );
              });
        },
      ),
      StreamBuilder<List<Event>>(
        stream: service.onDoneEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Text("Error: ${snapshot.error}");
          var events = snapshot.data!;
          return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                return ListTile(
                  title: Text(event.name),
                  subtitle: Text(event.isCanceled ? "Canceled" : ""),
                  onTap: () => openDialog(event),
                );
              });
        },
      )
    ];
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () => openDialog(null),
            label: const Text("Create event"),
            icon: const Icon(PhosphorIcons.plusLight)),
        body: Center(
          child: widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar:
            BottomNavigationBar(items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              activeIcon: Icon(PhosphorIcons.squareFill),
              icon: Icon(PhosphorIcons.squareLight),
              label: 'Opened'),
          BottomNavigationBarItem(
              activeIcon: Icon(PhosphorIcons.calendarFill),
              icon: Icon(PhosphorIcons.calendarLight),
              label: 'Planned'),
          BottomNavigationBarItem(
              activeIcon: Icon(PhosphorIcons.checkSquareFill),
              icon: Icon(PhosphorIcons.checkSquareLight),
              label: 'Done'),
        ], currentIndex: _selectedIndex, onTap: _onItemTapped));
  }
}
