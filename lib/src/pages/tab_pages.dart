part of '../../routemaster.dart';

class IndexedPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  IndexedPage({
    required this.child,
    required this.paths,
  });

  @override
  _PageState createState(Routemaster delegate, RouteInfo routeInfo) {
    return IndexedPageState(this, delegate, routeInfo);
  }

  static IndexedPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_IndexedPageStateProvider>()!
        .pageState;
  }
}

class _IndexedPageStateProvider extends InheritedNotifier {
  final IndexedPageState pageState;

  _IndexedPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState._delegate,
        );

  @override
  bool updateShouldNotify(covariant _IndexedPageStateProvider oldWidget) {
    return pageState != oldWidget.pageState;
  }
}

class IndexedPageState
    with _PageState, _PageCreator, ChangeNotifier, IndexedPageStateMixIn {
  @override
  final IndexedPage _page;

  @override
  final Routemaster _delegate;

  @override
  final RouteInfo _routeInfo;

  IndexedPageState(
    this._page,
    this._delegate,
    this._routeInfo,
  ) {
    _routes = List.filled(_page.paths.length, null);
  }
  @override
  Page _createPage() {
    return MaterialPage<void>(
      child: _IndexedPageStateProvider(
        pageState: this,
        child: _page.child,
      ),
      key: ValueKey(_routeInfo),
    );
  }
}

class TabPage extends StatefulPage<void> with IndexedRouteMixIn {
  // TODO: This should probably take a page and not a widget
  final Widget child;

  @override
  final List<String> paths;

  TabPage({
    required this.child,
    required this.paths,
  });

  @override
  _PageState createState(Routemaster delegate, RouteInfo routeInfo) {
    return TabPageState(this, delegate, routeInfo);
  }

  static TabPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TabPageStateProvider>()!
        .pageState;
  }
}

class _TabPageStateProvider extends InheritedNotifier {
  final TabPageState pageState;

  _TabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState._delegate,
        );

  @override
  bool updateShouldNotify(covariant _TabPageStateProvider oldWidget) {
    return pageState != oldWidget.pageState;
  }
}

class TabPageState
    with _PageState, _PageCreator, ChangeNotifier, IndexedPageStateMixIn {
  @override
  final TabPage _page;

  @override
  final Routemaster _delegate;

  @override
  final RouteInfo _routeInfo;

  TabPageState(this._page, this._delegate, this._routeInfo) {
    _routes = List.filled(_page.paths.length, null);
  }

  @override
  Page _createPage() {
    return MaterialPage<void>(
      key: ValueKey(_routeInfo),
      child: _TabControllerProvider(
        pageState: this,
        child: _TabPageStateProvider(
          pageState: this,
          child: Builder(builder: (_) => _page.child),
        ),
      ),
    );
  }

  TabController? _tabController;
  TabController get tabController => _tabController!;
}

/// Creates a [TabController] for [TabPageState]
class _TabControllerProvider extends StatefulWidget {
  final Widget child;
  final TabPageState pageState;

  _TabControllerProvider({
    required this.child,
    required this.pageState,
  });

  @override
  _TabControllerProviderState createState() => _TabControllerProviderState();
}

class _TabControllerProviderState extends State<_TabControllerProvider>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    final tabController = TabController(
      length: widget.pageState._routes.length,
      initialIndex: widget.pageState.index,
      vsync: this,
    );

    tabController.addListener(() {
      widget.pageState.index = tabController.index;
    });

    widget.pageState._tabController = tabController;
  }

  @override
  void dispose() {
    widget.pageState._tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class CupertinoTabPage extends StatefulPage<void> with IndexedRouteMixIn {
  final Widget child;

  @override
  final List<String> paths;

  CupertinoTabPage({
    required this.child,
    required this.paths,
  });

  @override
  _PageState createState(Routemaster delegate, RouteInfo routeInfo) {
    return CupertinoTabPageState(this, delegate, routeInfo);
  }

  static CupertinoTabPageState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CupertinoTabPageStateProvider>()!
        .pageState;
  }
}

class _CupertinoTabPageStateProvider extends InheritedNotifier {
  final CupertinoTabPageState pageState;

  _CupertinoTabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState._delegate,
        );

  @override
  bool updateShouldNotify(covariant _CupertinoTabPageStateProvider oldWidget) {
    return pageState != oldWidget.pageState;
  }
}

class CupertinoTabPageState
    with _PageState, _PageCreator, ChangeNotifier, IndexedPageStateMixIn {
  @override
  final CupertinoTabPage _page;

  @override
  final Routemaster _delegate;

  @override
  final RouteInfo _routeInfo;

  final CupertinoTabController tabController = CupertinoTabController();

  CupertinoTabPageState(
    this._page,
    this._delegate,
    this._routeInfo,
  ) {
    _routes = List.filled(_page.paths.length, null);

    addListener(() {
      if (index != tabController.index) {
        tabController.index = index;
      }
    });

    tabController.addListener(() {
      index = tabController.index;
    });
  }

  @override
  Page _createPage() {
    return MaterialPage<void>(
      child: _CupertinoTabPageStateProvider(
        pageState: this,
        child: _page.child,
      ),
      key: ValueKey(_routeInfo),
    );
  }

  Widget tabBuilder(BuildContext context, int index) {
    final stack = _getStackForIndex(index);
    final pages = stack.createPages();

    assert(pages.isNotEmpty, 'Pages must not be empty');

    return Navigator(
      key: stack.navigatorKey,
      onPopPage: stack.onPopPage,
      pages: pages,
    );
  }
}

mixin IndexedRouteMixIn<T> on Page<T> {
  List<String> get paths;
}

mixin IndexedPageStateMixIn on _PageCreator, ChangeNotifier {
  late List<StackPageState?> _routes;

  Routemaster get _delegate;

  @override
  RouteInfo get _routeInfo;

  IndexedRouteMixIn get _page;

  StackList? _stacks;
  StackList get stacks => _stacks ??= StackList(this);

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;

      notifyListeners();
      _delegate._markNeedsUpdate();
    }
  }

  StackPageState _getStackForIndex(int index) {
    if (_routes[index] == null) {
      final path = join(_routeInfo.path, _page.paths[index]);
      final route = _delegate._getPageState(path);
      if (route != null) {
        _routes[index] = StackPageState(
          delegate: _delegate,
          routes: [route],
        );
      }
    }

    return _routes[index]!;
  }

  int? _getIndexForPath(String path) {
    var i = 0;
    for (var initialPath in _page.paths) {
      if (path.startsWith(initialPath)) {
        return i;
      }
      i++;
    }

    return null;
  }

  @override
  bool _maybeSetPageStates(Iterable<_PageState> routes) {
    assert(
      routes.isNotEmpty,
      "Don't call maybeSetPageStates with an empty list",
    );

    final tabPagePath = _routeInfo.path;
    final subPagePath = routes.first._routeInfo.path;

    if (!isWithin(tabPagePath, subPagePath)) {
      return false;
    }

    final index = _getIndexForPath(_stripPath(tabPagePath, subPagePath));
    if (index == null) {
      return false;
    }

    _getStackForIndex(index)._setPageStates(routes.toList());
    this.index = index;
    return true;
  }

  static String _stripPath(String parent, String child) {
    final splitParent = split(parent);
    final splitChild = split(child);
    return joinAll(splitChild.skip(splitParent.length));
  }

  @override
  bool _maybePush(_PageState route) {
    final index = _getIndexForPath(route._routeInfo.path);
    if (index == null) {
      return false;
    }

    _getStackForIndex(index)._push(route);
    return true;
  }

  @override
  Future<bool> _maybePop() {
    return _getStackForIndex(index)._maybePop();
  }

  @override
  Iterable<_PageState> _getCurrentPageStates() sync* {
    yield this;
    yield* _getStackForIndex(index)._getCurrentPageStates();
  }
}

class StackList {
  final IndexedPageStateMixIn _indexedPageState;

  StackList(this._indexedPageState);

  StackPageState operator [](int index) =>
      _indexedPageState._getStackForIndex(index);
}
