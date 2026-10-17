import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Главная страница с переходом в разделы.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Библиотечная система')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Учебный клиент библиотечной системы',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Списки, поиск, фильтрация, сортировка и постраничный '
                  'вывод. Все условия отбора сохраняются в адресе страницы, '
                  'поэтому ссылку на отфильтрованный список можно передать '
                  'коллеге.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    _HomeCard(
                      icon: Icons.menu_book,
                      title: 'Каталог книг',
                      subtitle: 'Поиск по названию и ISBN, фильтры по жанру, '
                          'издательству и году',
                      onTap: () => context.go('/books'),
                    ),
                    _HomeCard(
                      icon: Icons.person,
                      title: 'Авторы',
                      subtitle: 'Поиск по фамилии и стране, '
                          'фильтр по году рождения',
                      onTap: () => context.go('/authors'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 36, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
