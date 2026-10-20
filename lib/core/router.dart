import 'package:go_router/go_router.dart';
import '../models/hall_query.dart';
import '../models/photographer_query.dart';
import '../screens/hall_list_screen.dart';
import '../screens/home_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/photographer_list_screen.dart';

final appRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(
          path: '/halls',
          builder: (_, s) => HallListScreen(query: HallQuery.fromUri(s.uri))),
      GoRoute(
          path: '/photographers',
          builder: (_, s) =>
              PhotographerListScreen(query: PhotographerQuery.fromUri(s.uri)))
    ],
    errorBuilder: (_, s) => NotFoundScreen(location: s.uri.toString()));
