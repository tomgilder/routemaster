import 'package:book_store/page_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';
import 'package:collection/collection.dart';

import 'book_card.dart';
import 'models.dart';

class WishlistHomePage extends StatelessWidget {
  const WishlistHomePage();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (!appState.isLoggedIn) {
      return PageScaffold(
        title: 'Wishlists',
        body: Center(child: Text('Please log in first')),
      );
    }

    return PageScaffold(
      title: 'Wishlist',
      body: ListView(
        padding: EdgeInsets.all(50),
        children: [
          if (appState.wishlists.isEmpty)
            Center(child: Text("You don't have any wishlists")),
          for (final wishlist in appState.wishlists)
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wishlist.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text('Share: ${wishlist.shareUrl}'),
                ],
              ),
              onTap: () {
                Routemaster.of(context).push(wishlist.shareUrl);
              },
            ),
          SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () => Routemaster.of(context).push('add'),
              child: Text('Add a new wishlist'),
            ),
          ),
        ],
      ),
    );
  }
}

class WishlistPage extends StatelessWidget {
  final String? id;

  const WishlistPage({required this.id});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final wishList = appState.wishlists.firstWhereOrNull(
      (list) => list.id == id,
    );
    final books = BooksDatabase().books;

    if (wishList == null) {
      return PageScaffold(
        title: 'Wishlist',
        body: ListView(
          children: [Text("No wishlist with ID '$id'")],
        ),
      );
    }

    return PageScaffold(
      title: 'Wishlist',
      body: ListView(
        children: [
          Text(
            'Wishlist ${wishList.title}',
            style: Theme.of(context).textTheme.headline4,
          ),
          Text('Share this wishlist! ${wishList.shareUrl}'),
          for (final bookId in wishList.bookIds)
            BookCard(
              book: books.firstWhere((book) => book.id == bookId),
            ),
        ],
      ),
    );
  }
}

class AddWishlistPage extends Page<void> {
  @override
  Route<void> createRoute(BuildContext context) {
    return DialogRoute(
      context: context,
      builder: (context) => AddWishlistDialog(),
      settings: this,
    );
  }
}

class AddWishlistDialog extends StatefulWidget {
  static const nameFieldKey = Key('name-field');

  @override
  _AddWishlistDialogState createState() => _AddWishlistDialogState();
}

class _AddWishlistDialogState extends State<AddWishlistDialog> {
  final _titleController = TextEditingController();
  final _pickedBooks = Set<String>();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _bookTapped(String bookId) {
    setState(() {
      if (_pickedBooks.contains(bookId)) {
        _pickedBooks.remove(bookId);
      } else {
        _pickedBooks.add(bookId);
      }
    });
  }

  void _addWishlist() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.addWishlist(
      Wishlist(
        id: 'list-${appState.wishlists.length + 1}',
        bookIds: _pickedBooks.toList(),
        title: _titleController.text,
        username: appState.username,
      ),
    );
    Routemaster.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (!appState.isLoggedIn) {
      return Text('Please log in first');
    }

    return Center(
      child: Material(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        type: MaterialType.card,
        child: Container(
          width: 700,
          height: 500,
          child: Center(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Add a new wishlist'),
                ),
                Text('Name'),
                CupertinoTextField(
                  controller: _titleController,
                  key: AddWishlistDialog.nameFieldKey,
                ),
                Text('Choose some books'),
                Container(
                  height: 200,
                  child: ListView(
                    children: [
                      Wrap(
                        children: [
                          for (final book in BooksDatabase().books)
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xfffebd68),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(10),
                              child: InkWell(
                                onTap: () => _bookTapped(book.id),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_pickedBooks.contains(book.id))
                                      Icon(Icons.check_circle_outline)
                                    else
                                      Icon(Icons.radio_button_unchecked),
                                    SizedBox(width: 8),
                                    Flexible(child: Text(book.title)),
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: AnimatedBuilder(
                    animation: _titleController,
                    builder: (_, __) => ElevatedButton(
                      onPressed:
                          _titleController.text.isEmpty || _pickedBooks.isEmpty
                              ? null
                              : _addWishlist,
                      child: Text('Add wishlist'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
