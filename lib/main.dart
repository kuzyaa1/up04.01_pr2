import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'core/router.dart';
import 'repositories/hall_repository.dart';
import 'repositories/in_memory_hall_repository.dart';
import 'repositories/in_memory_photographer_repository.dart';
import 'repositories/photographer_repository.dart';
import 'state/list_notifiers.dart';

void main() {
  usePathUrlStrategy();
  runApp(MultiProvider(providers: [
    Provider<HallRepository>(create: (_) => InMemoryHallRepository()),
    Provider<PhotographerRepository>(
        create: (_) => InMemoryPhotographerRepository()),
    ChangeNotifierProvider(
        create: (c) => HallListNotifier(c.read<HallRepository>())),
    ChangeNotifierProvider(
        create: (c) =>
            PhotographerListNotifier(c.read<PhotographerRepository>()))
  ], child: const PhotoStudioApp()));
}

class PhotoStudioApp extends StatelessWidget {
  const PhotoStudioApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp.router(
      title: 'FocusFrame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true),
      routerConfig: appRouter);
}
