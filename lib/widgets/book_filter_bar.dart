import 'dart:async';

import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/book_query.dart';

/// Панель фильтров каталога книг.
///
/// Панель ничего не знает про состояние: она лишь сообщает наружу новый
/// объект условий отбора. Поле поиска запускает выборку не на каждое
/// нажатие клавиши, а через 350 мс после окончания ввода.
class BookFilterBar extends StatefulWidget {
  final BookQuery query;
  final ValueChanged<BookQuery> onChanged;

  const BookFilterBar({
    super.key,
    required this.query,
    required this.onChanged,
  });

  @override
  State<BookFilterBar> createState() => _BookFilterBarState();
}

class _BookFilterBarState extends State<BookFilterBar> {
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
  void didUpdateWidget(BookFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Синхронизируем поля с адресом только при реальной смене условий,
    // иначе ввод пользователя затирался бы перерисовками списка.
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
                labelText: 'Поиск: название или ISBN',
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
            width: 200,
            child: DropdownButtonFormField<int?>(
              value: query.genreId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Жанр',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Все жанры'),
                ),
                for (final genre in genres)
                  DropdownMenuItem<int?>(
                    value: genre.id,
                    child: Text(genre.name),
                  ),
              ],
              onChanged: (value) =>
                  widget.onChanged(query.copyWith(genreId: value)),
            ),
          ),
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<int?>(
              value: query.publisherId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Издательство',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Все издательства'),
                ),
                for (final publisher in publishers)
                  DropdownMenuItem<int?>(
                    value: publisher.id,
                    child: Text(publisher.name),
                  ),
              ],
              onChanged: (value) =>
                  widget.onChanged(query.copyWith(publisherId: value)),
            ),
          ),
          SizedBox(
            width: 110,
            child: TextField(
              controller: _yearFrom,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Год от',
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
            width: 110,
            child: TextField(
              controller: _yearTo,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Год до',
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
              const Text('Показывать удалённые'),
            ],
          ),
          TextButton.icon(
            onPressed: query.hasActiveFilters
                ? () => widget.onChanged(
                      BookQuery(
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
