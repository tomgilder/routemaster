import 'package:book_store/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'book_card.dart';
import 'models.dart';

class AudiobookPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tabState = TabPage.of(context);

    return PageScaffold(
      title: 'Audiobooks',
      body: ListView(
        children: [
          Container(
            color: Color(0xff202f3f),
            height: 70,
            child: TabBar(
              indicatorWeight: 6,
              controller: tabState.tabController,
              tabs: [
                Tab(icon: Icon(Icons.list), text: 'All Audiobooks'),
                Tab(icon: Icon(Icons.star), text: 'Staff picks'),
              ],
            ),
          ),
          Container(
            height: 500,
            child: TabBarView(
              controller: tabState.tabController,
              children: <Widget>[
                Navigator(
                  pages: tabState.stacks[0].createPages(),
                  onPopPage: tabState.stacks[0].onPopPage,
                  key: tabState.stacks[0].navigatorKey,
                ),
                Navigator(
                  pages: tabState.stacks[1].createPages(),
                  onPopPage: tabState.stacks[1].onPopPage,
                  key: tabState.stacks[1].navigatorKey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudiobookListPage extends StatelessWidget {
  final String mode;

  const AudiobookListPage({required this.mode});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Wrap(
          children: [
            if (mode == 'picks')
              for (final book
                  in BooksDatabase().books.where((book) => book.isStaffPick))
                BookCard(
                  book: book,
                  pathBuilder: (id) => '/audiobooks/book/$id',
                )
            else
              for (final book in BooksDatabase().books)
                BookCard(
                  book: book,
                  pathBuilder: (id) => '/audiobooks/book/$id',
                ),
          ],
        ),
      ],
    );
  }
}
