import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/seed_data.dart';
import '../models/photographer.dart';
import '../models/photographer_query.dart';
import '../state/list_notifiers.dart';
import '../widgets/common.dart';
import '../widgets/entity_table.dart';

class PhotographerListScreen extends StatefulWidget {
  final PhotographerQuery query;
  const PhotographerListScreen({super.key, required this.query});
  @override
  State<PhotographerListScreen> createState() => _PhotographerListScreenState();
}

class _PhotographerListScreenState extends State<PhotographerListScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => sync());
  }

  @override
  void didUpdateWidget(covariant PhotographerListScreen old) {
    super.didUpdateWidget(old);
    if (old.query.toQueryParameters().toString() !=
        widget.query.toQueryParameters().toString()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => sync());
    }
  }

  void sync() =>
      context.read<PhotographerListNotifier>().applyQuery(widget.query);
  void go(PhotographerQuery q) {
    final p = q.toQueryParameters();
    context.go(p.isEmpty
        ? '/photographers'
        : Uri(path: '/photographers', queryParameters: p).toString());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final n = c.watch<PhotographerListNotifier>();
    return AppScaffold(
        title: 'Фотографы',
        index: 1,
        child: Column(children: [
          filters(n),
          if (n.hasSelection) selection(n),
          Expanded(child: body(n)),
          if (n.status == LoadStatus.success && n.result.total > 0)
            Pager(
                page: n.result.page,
                totalPages: n.result.totalPages,
                total: n.result.total,
                size: n.result.size,
                onPage: (x) => go(n.query.copyWith(page: x)),
                onSize: (x) => go(n.query.copyWith(size: x)))
        ]));
  }

  Widget filters(PhotographerListNotifier n) {
    final q = widget.query;
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          SizedBox(
              width: 280,
              child: TextFormField(
                  initialValue: q.search,
                  decoration: const InputDecoration(
                      labelText: 'Поиск: фамилия или специализация',
                      border: OutlineInputBorder()),
                  onChanged: (v) {
                    timer?.cancel();
                    timer = Timer(const Duration(milliseconds: 350),
                        () => go(q.copyWith(search: v)));
                  })),
          SizedBox(
              width: 270,
              child: DropdownButtonFormField<String?>(
                  value: q.specialization,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Специализация', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Все специализации',
                            overflow: TextOverflow.ellipsis)),
                    ...photographerSpecializations.map((v) =>
                        DropdownMenuItem<String?>(
                            value: v,
                            child: Text(v, overflow: TextOverflow.ellipsis)))
                  ],
                  onChanged: (v) => go(q.copyWith(specialization: v)))),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Switch(
                value: q.includeDeleted,
                onChanged: (v) => go(q.copyWith(includeDeleted: v))),
            const Text('Удалённые')
          ]),
          TextButton(
              onPressed: q.hasActiveFilters
                  ? () => go(PhotographerQuery(
                      size: q.size,
                      sortField: q.sortField,
                      sortAscending: q.sortAscending))
                  : null,
              child: const Text('Сбросить'))
        ]));
  }

  Widget selection(PhotographerListNotifier n) => Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(spacing: 8, children: [
        Text('Выбрано: ${n.selected.length}'),
        FilledButton(
            onPressed: () async {
              if (await confirm(context, 'Удалить выбранных?')) {
                await n.deleteSelected(false);
              }
            },
            child: const Text('Удалить')),
        OutlinedButton(
            onPressed: () async {
              if (await confirm(context, 'Стереть выбранных?', hard: true)) {
                await n.deleteSelected(true);
              }
            },
            child: const Text('Стереть навсегда')),
        TextButton(onPressed: n.clear, child: const Text('Снять выделение'))
      ]));
  Widget body(PhotographerListNotifier n) {
    if (n.status == LoadStatus.idle || n.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (n.status == LoadStatus.error) {
      return StatusView(text: n.error ?? 'Ошибка', error: true, retry: n.load);
    }
    if (n.result.items.isEmpty) {
      return const StatusView(text: 'Фотографы не найдены.');
    }
    if (MediaQuery.sizeOf(context).width < compactWidth) {
      return ListView(children: [for (final p in n.result.items) card(n, p)]);
    }
    return EntityTable<Photographer>(
        items: n.result.items,
        id: (p) => p.id,
        selected: n.selected,
        toggle: n.toggle,
        sort: n.query.sortField,
        asc: n.query.sortAscending,
        onSort: (f) => go(n.query.copyWith(
            sortField: f,
            sortAscending:
                f == n.query.sortField ? !n.query.sortAscending : true)),
        columns: [
          (
            'Фамилия',
            'lastName',
            (p) => Text(p.isDeleted ? '${p.lastName} (удалён)' : p.lastName)
          ),
          ('Имя', null, (p) => Text(p.firstName)),
          ('Специализация', 'specialization', (p) => Text(p.specialization)),
          ('Стаж', 'experienceYears', (p) => Text('${p.experienceYears} лет')),
          ('Цена/час', 'hourlyRate', (p) => Text('${p.hourlyRate} ₽'))
        ],
        actions: (p) => actions(n, p));
  }

  Widget card(PhotographerListNotifier n, Photographer p) => Card(
      child: ListTile(
          leading: Checkbox(
              value: n.selected.contains(p.id),
              onChanged: (_) => n.toggle(p.id)),
          title: Text(p.fullName),
          subtitle: Text(
              '${p.specialization}\nСтаж: ${p.experienceYears} лет • ${p.hourlyRate} ₽/час'),
          isThreeLine: true,
          trailing: Wrap(children: actions(n, p))));
  List<Widget> actions(PhotographerListNotifier n, Photographer p) => [
        if (p.isDeleted)
          IconButton(
              onPressed: () => n.restore(p.id), icon: const Icon(Icons.restore))
        else
          IconButton(
              onPressed: () async {
                if (await confirm(
                    context, 'Удалить фотографа «${p.fullName}»?')) {
                  await n.softDelete(p.id);
                }
              },
              icon: const Icon(Icons.delete_outline)),
        IconButton(
            onPressed: () async {
              if (await confirm(context, 'Стереть фотографа «${p.fullName}»?',
                  hard: true)) {
                await n.hardDelete(p.id);
              }
            },
            icon: const Icon(Icons.delete_forever))
      ];
}
