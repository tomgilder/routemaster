import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:intl/intl.dart';
import 'models.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final void Function() onTap;

  const CustomCard({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 350,
        child: Material(
          color: Color(0xfffebd68),
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final bool showReleaseDate;
  final String Function(String id)? pathBuilder;

  const BookCard({
    required this.book,
    this.showReleaseDate = false,
    this.pathBuilder,
  });

  static final _formatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () {
        Routemaster.of(context).push(
            pathBuilder != null ? pathBuilder!(book.id) : '/book/${book.id}');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            height: 100,
            width: 75,
            child: Icon(
              CupertinoIcons.book,
              size: 55,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(fontSize: 16),
                ),
                if (showReleaseDate) Text(_formatter.format(book.releaseDate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
