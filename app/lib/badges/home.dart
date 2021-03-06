import 'package:flow/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get_it/get_it.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared/models/badge.dart';
import 'package:shared/services/api_service.dart';
import 'package:shared/services/local/service.dart';

import 'details.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({Key? key}) : super(key: key);

  @override
  _BadgesPageState createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  Badge? selected;
  late BadgesApiService service;
  late Stream<List<Badge>> badgeStream;

  @override
  void initState() {
    super.initState();

    service = GetIt.I.get<LocalService>().badges;
    badgeStream = service.onBadges();
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
        page: RoutePages.badges,
        pageTitle: "Badges",
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(PhosphorIcons.funnelLight))
        ],
        body: LayoutBuilder(builder: (context, constraints) {
          var isDesktop = MediaQuery.of(context).size.width > 1000;
          return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                if (isDesktop) ...[
                  Expanded(
                      flex: 2,
                      child: BadgePage(isDesktop: isDesktop, id: selected?.id)),
                  const VerticalDivider()
                ],
                Expanded(
                    flex: 3,
                    child: Scaffold(
                        floatingActionButton: selected == null && isDesktop
                            ? null
                            : FloatingActionButton.extended(
                                label: const Text("Create badge"),
                                icon: const Icon(PhosphorIcons.plusLight),
                                onPressed: () => isDesktop
                                    ? setState(() => selected = null)
                                    : Modular.to.pushNamed("/badges/create")),
                        body: Scrollbar(
                            child: SingleChildScrollView(
                                child: StreamBuilder<List<Badge>>(
                                    stream: badgeStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text("Error: ${snapshot.error}");
                                      }
                                      if (snapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          !snapshot.hasData) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      var badges = snapshot.data!;
                                      return Column(
                                          children: List.generate(badges.length,
                                              (index) {
                                        var badge = badges[index];
                                        return Dismissible(
                                          key: Key(badge.id!.toString()),
                                          onDismissed: (direction) {
                                            service.deleteBadge(badge.id!);
                                          },
                                          background:
                                              Container(color: Colors.red),
                                          child: ListTile(
                                              title: Text(badge.name),
                                              selected:
                                                  selected?.id == badge.id,
                                              onTap: () => isDesktop
                                                  ? setState(
                                                      () => selected = badge)
                                                  : Modular.to.pushNamed(
                                                      Uri(pathSegments: [
                                                      "",
                                                      "badges",
                                                      "details"
                                                    ], queryParameters: {
                                                      "id": badge.id.toString()
                                                    }).toString())),
                                        );
                                      }));
                                    })))))
              ]);
        }));
  }
}
