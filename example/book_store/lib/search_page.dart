import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:collection/collection.dart';
import 'book_card.dart';
import 'models.dart';
import 'page_scaffold.dart';

enum SortOrder { name, date }

extension SortOrderExtension on SortOrder {
  String get displayName {
    switch (this) {
      case SortOrder.name:
        return 'Name';
      case SortOrder.date:
        return 'Release date';
    }
  }

  String get queryParam {
    switch (this) {
      case SortOrder.name:
        return 'name';
      case SortOrder.date:
        return 'date';
    }
  }
}

class SearchPage extends StatelessWidget {
  final String query;
  final SortOrder sortOrder;

  const SearchPage({
    required this.query,
    this.sortOrder = SortOrder.name,
  });

  @override
  Widget build(BuildContext context) {
    final books = BooksDatabase()
        .books
        .where(
          (book) => book.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList()
        .sorted(
          (a, b) => sortOrder == SortOrder.name
              ? a.title.compareTo(b.title)
              : a.releaseDate.compareTo(b.releaseDate),
        );

    final categoryMatches = BookCategory.values.where((category) =>
        category.displayName.toLowerCase().contains(query.toLowerCase()));

    return PageScaffold(
      title: 'Search Results',
      searchQuery: query,
      body: ListView(
        padding: const EdgeInsets.all(50),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Sort by:"),
              SizedBox(width: 10),
              DropdownButton<SortOrder>(
                value: sortOrder,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (SortOrder? newValue) {
                  Routemaster.of(context).replace('/search', queryParameters: {
                    'query': query,
                    if (newValue != null) 'sort': newValue.queryParam,
                  });
                },
                items: SortOrder.values.map((SortOrder value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value.displayName),
                  );
                }).toList(),
              ),
              SizedBox(width: 30),
            ],
          ),
          if (categoryMatches.isNotEmpty) ...[
            Text(
              'Categories',
              style: Theme.of(context).textTheme.headline5,
            ),
            for (final category in categoryMatches) ...[
              Container(
                child: Text(
                  category.displayName,
                ),
              ),
              for (final book in BooksDatabase()
                  .books
                  .where((book) => book.categories.contains(category)))
                BookCard(
                  book: book,
                  pathBuilder: (id) =>
                      '/category/${category.queryParam}/book/$id',
                )
            ]
          ],
          Text(
            'Books',
            style: Theme.of(context).textTheme.headline5,
          ),
          if (books.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Text('No results found'),
            )
          else
            for (final book in books)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BookCard(
                  book: book,
                  showReleaseDate: true,
                ),
              )
        ],
      ),
    );
  }
}
