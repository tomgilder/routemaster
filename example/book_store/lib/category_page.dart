import 'package:flutter/material.dart';
import 'book_card.dart';
import 'models.dart';
import 'page_scaffold.dart';

class CategoryPage extends StatelessWidget {
  final BookCategory category;

  const CategoryPage({required this.category});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "Dash's book shop",
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              category.displayName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Wrap(
            children: [
              for (final book in BooksDatabase()
                  .books
                  .where((book) => book.categories.contains(category)))
                BookCard(book: book),
            ],
          ),
        ],
      ),
    );
  }
}
