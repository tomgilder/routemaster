import 'package:book_store/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routemaster/routemaster.dart';

class PageScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final String? searchQuery;

  PageScaffold({
    required this.title,
    required this.body,
    this.searchQuery,
  });

  @override
  _PageScaffoldState createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _updateSearchQuery();
  }

  @override
  void didUpdateWidget(covariant PageScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateSearchQuery();
  }

  void _updateSearchQuery() {
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
  }

  void _search() {
    Routemaster.of(context).push(
      '/search',
      queryParameters: {'query': _searchController.text},
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;

      return Scaffold(
        drawer: isMobile
            ? Drawer(
                child: Container(
                  color: Color(0xFF232f3e),
                  child: ListView(
                    children: _buildNavBarChildren(inDrawer: true),
                  ),
                ),
              )
            : null,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 70),
          child: isMobile
              ? AppBar(
                  automaticallyImplyLeading: isMobile,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 200,
                    ),
                  ),
                )
              : AppBar(
                  automaticallyImplyLeading: isMobile,
                  title: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Container(
                          height: 200,
                          child: Image.asset(
                            'assets/logo.png',
                            width: 200,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(widget.title),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        body: Column(
          children: [
            Container(
              color: Color(0xFF232f3e),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 70,
                    child: ModalRoute.of(context)!.canPop
                        ? const BackButton(color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            width: 300,
                            padding: EdgeInsets.all(16),
                            child: CupertinoTextField(
                              controller: _searchController,
                              onSubmitted: (_) => _search(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _search,
                          child: Text('Search'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  if (appState.isLoggedIn)
                    Text(
                      'Hello, ${appState.username}!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    InkWell(
                      onTap: () {
                        Routemaster.of(context).push(
                          '/login',
                          queryParameters: {
                            'redirectTo': RouteData.of(context).fullPath,
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(width: 20),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  if (!isMobile)
                    Container(
                      width: 200,
                      color: Color(0xFF232f3e),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildNavBarChildren(inDrawer: false),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: widget.body,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildNavBarChildren({required bool inDrawer}) {
    return [
      NavigationLink(
        title: 'Fiction',
        path: '/category/fiction',
        inDrawer: inDrawer,
      ),
      NavigationLink(
        title: 'Non-fiction',
        path: '/category/nonfiction',
        inDrawer: inDrawer,
      ),
      NavigationLink(
        title: 'Audiobooks',
        path: '/audiobooks',
        inDrawer: inDrawer,
      ),
      NavigationLink(
        title: 'Wishlists',
        path: '/wishlist',
        inDrawer: inDrawer,
      ),
    ];
  }
}

class NavigationLink extends StatelessWidget {
  final String title;
  final String path;
  final bool inDrawer;

  const NavigationLink({
    required this.title,
    required this.path,
    required this.inDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final currentPath = RouteData.of(context).fullPath;
    final isCurrent = currentPath.startsWith(path);

    return Container(
      color: isCurrent ? Color(0xff068597) : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (inDrawer) {
            Navigator.pop(context);
          }

          Routemaster.of(context).push(path);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
