import 'package:flutter_modular/flutter_modular.dart';

import 'appearance.dart';
import 'information.dart';

class SettingsModule extends Module {
  // Provide a list of dependencies to inject into your project
  @override
  final List<Bind> binds = [];

  // Provide all the routes for your module
  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => const InformationPage()),
    ChildRoute('/appearance', child: (_, __) => const AppearanceSettingsPage())
  ];
}
