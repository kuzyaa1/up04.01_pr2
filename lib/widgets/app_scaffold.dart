import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';

/// Каркас приложения с адаптивной навигацией.
///
/// На узком окне навигация снизу (как на телефоне), на широком —
/// боковая полоса.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final int selectedIndex;
  final List<Widget> actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.selectedIndex,
    this.actions = const <Widget>[],
  });

  static const _destinations = [
    (icon: Icons.menu_book, label: 'Книги', path: '/books'),
    (icon: Icons.person, label: 'Авторы', path: '/authors'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = screenSizeOf(context);
    final appBar = AppBar(title: Text(title), actions: actions);

    if (size == ScreenSize.compact) {
      return Scaffold(
        appBar: appBar,
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              context.go(_destinations[index].path),
          destinations: [
            for (final d in _destinations)
              NavigationDestination(icon: Icon(d.icon), label: d.label),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) =>
                context.go(_destinations[index].path),
            extended: size == ScreenSize.expanded,
            labelType: size == ScreenSize.expanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: [
              for (final d in _destinations)
                NavigationRailDestination(
                  icon: Icon(d.icon),
                  label: Text(d.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
