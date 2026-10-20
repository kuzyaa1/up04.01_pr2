import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/seed_data.dart';
import '../models/hall_query.dart';
import '../models/studio_hall.dart';
import '../state/list_notifiers.dart';
import '../widgets/common.dart';
import '../widgets/entity_table.dart';

class HallListScreen extends StatefulWidget {
  final HallQuery query;
  const HallListScreen({super.key, required this.query});
  @override
  State<HallListScreen> createState() => _HallListScreenState();
}

class _HallListScreenState extends State<HallListScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(covariant HallListScreen old) {
    super.didUpdateWidget(old);
    if (old.query.toQueryParameters().toString() !=
        widget.query.toQueryParameters().toString()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
    }
  }

  void _sync() => context.read<HallListNotifier>().applyQuery(widget.query);
  void _go(HallQuery q) {
    final p = q.toQueryParameters();
    context.go(p.isEmpty
        ? '/halls'
        : Uri(path: '/halls', queryParameters: p).toString());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<HallListNotifier>();
    return AppScaffold(
        title: 'Залы фотостудии',
        index: 0,
        child: Column(children: [
          _filters(n),
          if (n.hasSelection) _selection(n),
          Expanded(child: _body(n)),
          if (n.status == LoadStatus.success && n.result.total > 0)
            Pager(
                page: n.result.page,
                totalPages: n.result.totalPages,
                total: n.result.total,
                size: n.result.size,
                onPage: (v) => _go(n.query.copyWith(page: v)),
                onSize: (v) => _go(n.query.copyWith(size: v)))
        ]));
  }

  Widget _filters(HallListNotifier n) {
    final q = widget.query;
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          SizedBox(
              width: 260,
              child: TextFormField(
                  initialValue: q.search,
                  decoration: const InputDecoration(
                      labelText: 'Поиск: зал или код',
                      border: OutlineInputBorder()),
                  onChanged: (v) {
                    _timer?.cancel();
                    _timer = Timer(const Duration(milliseconds: 350),
                        () => _go(q.copyWith(search: v)));
                  })),
          SizedBox(
              width: 180,
              child: DropdownButtonFormField<String?>(
                  value: q.style,
                  decoration: const InputDecoration(
                      labelText: 'Стиль', border: OutlineInputBorder()),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Все стили')),
                    ...hallStyles.map((v) =>
                        DropdownMenuItem<String?>(value: v, child: Text(v)))
                  ],
                  onChanged: (v) => _go(q.copyWith(style: v)))),
          SizedBox(
              width: 115,
              child: TextFormField(
                  initialValue: q.capacityFrom?.toString(),
                  decoration: const InputDecoration(
                      labelText: 'Мест от', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) =>
                      _go(q.copyWith(capacityFrom: int.tryParse(v))))),
          SizedBox(
              width: 115,
              child: TextFormField(
                  initialValue: q.capacityTo?.toString(),
                  decoration: const InputDecoration(
                      labelText: 'Мест до', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) =>
                      _go(q.copyWith(capacityTo: int.tryParse(v))))),
          SizedBox(
              width: 120,
              child: TextFormField(
                  initialValue: q.priceFrom?.toString(),
                  decoration: const InputDecoration(
                      labelText: 'Цена от', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) =>
                      _go(q.copyWith(priceFrom: int.tryParse(v))))),
          SizedBox(
              width: 120,
              child: TextFormField(
                  initialValue: q.priceTo?.toString(),
                  decoration: const InputDecoration(
                      labelText: 'Цена до', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) =>
                      _go(q.copyWith(priceTo: int.tryParse(v))))),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Switch(
                value: q.includeDeleted,
                onChanged: (v) => _go(q.copyWith(includeDeleted: v))),
            const Text('Удалённые')
          ]),
          TextButton(
              onPressed: q.hasActiveFilters
                  ? () => _go(HallQuery(
                      size: q.size,
                      sortField: q.sortField,
                      sortAscending: q.sortAscending))
                  : null,
              child: const Text('Сбросить'))
        ]));
  }

  Widget _selection(HallListNotifier n) => Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(spacing: 8, children: [
        Text('Выбрано: ${n.selected.length}'),
        FilledButton(
            onPressed: () async {
              if (await confirm(context, 'Удалить выбранные залы?')) {
                await n.deleteSelected(false);
              }
            },
            child: const Text('Удалить')),
        OutlinedButton(
            onPressed: () async {
              if (await confirm(context, 'Стереть выбранные залы?',
                  hard: true)) {
                await n.deleteSelected(true);
              }
            },
            child: const Text('Стереть навсегда')),
        TextButton(onPressed: n.clear, child: const Text('Снять выделение'))
      ]));
  Widget _body(HallListNotifier n) {
    if (n.status == LoadStatus.idle || n.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (n.status == LoadStatus.error) {
      return StatusView(text: n.error ?? 'Ошибка', error: true, retry: n.load);
    }
    if (n.result.items.isEmpty) {
      return const StatusView(text: 'Залы по заданным условиям не найдены.');
    }
    if (MediaQuery.sizeOf(context).width < compactWidth) {
      return ListView(children: [for (final h in n.result.items) _card(n, h)]);
    }
    return EntityTable<StudioHall>(
        items: n.result.items,
        id: (h) => h.id,
        selected: n.selected,
        toggle: n.toggle,
        sort: n.query.sortField,
        asc: n.query.sortAscending,
        onSort: (f) => _go(n.query.copyWith(
            sortField: f,
            sortAscending:
                f == n.query.sortField ? !n.query.sortAscending : true)),
        columns: [
          (
            'Название',
            'name',
            (h) => Text(h.isDeleted ? '${h.name} (удалён)' : h.name)
          ),
          ('Код', null, (h) => Text(h.code)),
          ('Стиль', 'style', (h) => Text(h.style)),
          ('Вместимость', 'capacity', (h) => Text('${h.capacity}')),
          ('Цена/час', 'hourlyRate', (h) => Text('${h.hourlyRate} ₽'))
        ],
        actions: (h) => _actions(n, h));
  }

  Widget _card(HallListNotifier n, StudioHall h) => Card(
      child: ListTile(
          leading: Checkbox(
              value: n.selected.contains(h.id),
              onChanged: (_) => n.toggle(h.id)),
          title: Text(h.name),
          subtitle: Text(
              '${h.code} • ${h.style}\n${h.capacity} чел. • ${h.hourlyRate} ₽/час'),
          isThreeLine: true,
          trailing: Wrap(children: _actions(n, h))));
  List<Widget> _actions(HallListNotifier n, StudioHall h) => [
        if (h.isDeleted)
          IconButton(
              onPressed: () => n.restore(h.id), icon: const Icon(Icons.restore))
        else
          IconButton(
              onPressed: () async {
                if (await confirm(context, 'Удалить зал «${h.name}»?')) {
                  await n.softDelete(h.id);
                }
              },
              icon: const Icon(Icons.delete_outline)),
        IconButton(
            onPressed: () async {
              if (await confirm(context, 'Стереть зал «${h.name}»?',
                  hard: true)) {
                await n.hardDelete(h.id);
              }
            },
            icon: const Icon(Icons.delete_forever))
      ];
}
