import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('FocusFrame — фотостудия')),
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Система бронирования фотостудии', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('Каталог залов и фотографов — основа будущего сервиса бронирования, оплаты и управления расписанием.', textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Wrap(spacing: 16, runSpacing: 16, children: [
            FilledButton.icon(onPressed: () => context.go('/halls'), icon: const Icon(Icons.meeting_room), label: const Text('Залы фотостудии')),
            FilledButton.icon(onPressed: () => context.go('/photographers'), icon: const Icon(Icons.camera_alt), label: const Text('Фотографы')),
          ]),
        ],
      )),
    )),
  );
}
