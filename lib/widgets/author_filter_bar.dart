import 'dart:async';

import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/author_query.dart';

/// Панель фильтров справочника авторов.
class AuthorFilterBar extends StatefulWidget {
  final AuthorQuery query;
  final ValueChanged<AuthorQuery> onChanged;

  const AuthorFilterBar({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  State<AuthorFilterBar> createState() => _AuthorFilterBarState();
}

class _AuthorFilterBarState extends State<AuthorFilterBar> {
  late final TextEditingController _search;
  late final TextEditingController _yearFrom;
  late final TextEditingController _yearTo;
  Timer? _searchTimer;
  Timer? _yearFromTimer;
  Timer? _yearToTimer;

  static const _debounce = Duration(milliseconds: 350);

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.query.search);
    _yearFrom =
        TextEditingController(text: widget.query.yearFrom?.toString() ?? '');
    _yearTo = TextEditingController(text: widget.query.yearTo?.toString() ?? '');
  }

  @override
  void didUpdateWidget(AuthorFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      if (_search.text != widget.query.search) {
        _search.text = widget.query.search;
      }
      final from = widget.query.yearFrom?.toString() ?? '';
      if (_yearFrom.text != from) _yearFrom.text = from;
      final to = widget.query.yearTo?.toString() ?? '';
      if (_yearTo.text != to) _yearTo.text = to;
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _yearFromTimer?.cancel();
    _yearToTimer?.cancel();
    _search.dispose();
    _yearFrom.dispose();
    _yearTo.dispose();
    super.dispose();
  }

  int? _parse(String value) => int.tryParse(value.trim());

  @override
  Widget build(BuildContext context) {
    final query = widget.query;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                labelText: 'Поиск: фамилия или страна',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: query.search.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Очистить',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          widget.onChanged(query.copyWith(search: ''));
                        },
                      ),
              ),
              onChanged: (value) {
                _searchTimer?.cancel();
                _searchTimer = Timer(
                  _debounce,
                  () => widget.onChanged(query.copyWith(search: value)),
                );
              },
            ),
          ),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String?>(
              value: query.country,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Страна',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Все страны'),
                ),
                for (final country in countries)
                  DropdownMenuItem<String?>(
                    value: country,
                    child: Text(country),
                  ),
              ],
              onChanged: (value) =>
                  widget.onChanged(query.copyWith(country: value)),
            ),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _yearFrom,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Год рожд. от',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                _yearFromTimer?.cancel();
                _yearFromTimer = Timer(
                  _debounce,
                  () => widget.onChanged(
                    query.copyWith(yearFrom: _parse(value)),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _yearTo,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Год рожд. до',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                _yearToTimer?.cancel();
                _yearToTimer = Timer(
                  _debounce,
                  () => widget.onChanged(query.copyWith(yearTo: _parse(value))),
                );
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: query.includeDeleted,
                onChanged: (value) =>
                    widget.onChanged(query.copyWith(includeDeleted: value)),
              ),
              const Text('Показывать удалённых'),
            ],
          ),
          TextButton.icon(
            onPressed: query.hasActiveFilters
                ? () => widget.onChanged(
                      AuthorQuery(
                        sortField: query.sortField,
                        sortAscending: query.sortAscending,
                        size: query.size,
                      ),
                    )
                : null,
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Сбросить фильтры'),
          ),
        ],
      ),
    );
  }
}
