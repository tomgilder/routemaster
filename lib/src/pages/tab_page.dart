part of '../../routemaster.dart';

/// A page used to manage tab views. Its state object creates and manages a
/// [TabController] that can be retrieved via `TabPage.of(context).controller`.
class TabPage extends StatefulPage<void> with IndexedRouteMixIn {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  @override
  final List<String> paths;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  /// Specifies how tabs behave when used with the system back button.
  final TabBackBehavior backBehavior;

  /// Initializes the page with a list of child [paths].
  const TabPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
    this.backBehavior = TabBackBehavior.none,
  });

  @override
  PageState createState() {
    return TabPageState();
  }

  /// Retrieves the nearest [TabPageState] ancestor.
  static TabPageState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_TabPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find a TabPageState from the given context.",
    );

    return provider!.pageState;
  }
}

class _TabPageStateProvider extends InheritedNotifier {
  final TabPageState pageState;

  const _TabPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState,
        );
}

/// The state for a [TabPage]. Creates and manages a [TabController] that can be
/// retrieved via `TabPage.of(context).controller`.
class TabPageState extends PageState<TabPage>
    with ChangeNotifier, IndexedPageStateMixIn {
  /// Initializes the state for a [TabPage].
  TabPageState();

  @override
  TabBackBehavior get backBehavior => page.backBehavior;

  @override
  void initState() {
    super.initState();
    _routes = List.filled(page.paths.length, null);
  }

  @override
  set index(int value) {
    if (_controller != null) {
      _controller!.index = value;
    }

    super.index = value;
  }

  @override
  Page createPage() {
    return page.pageBuilder(
      _TabControllerProvider(
        pageState: this,
        child: _TabPageStateProvider(
          pageState: this,
          child: page.child,
        ),
      ),
    );
  }

  /// The [TabController] for this page that can be passed to widgets such as
  /// `TabBar` and `TabBarView`.
  TabController get controller => _controller!;
  TabController? _controller;
}

/// Creates a [TabController] for [TabPageState]
class _TabControllerProvider extends StatefulWidget {
  final Widget child;
  final TabPageState pageState;

  const _TabControllerProvider({
    required this.child,
    required this.pageState,
  });

  @override
  _TabControllerProviderState createState() => _TabControllerProviderState();
}

class _TabControllerProviderState extends State<_TabControllerProvider>
    with TickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _updateController();
    widget.pageState._controller = _controller;
  }

  @override
  void didUpdateWidget(_TabControllerProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.pageState._routes.length != _controller!.length) {
      _updateController();
    }

    widget.pageState._controller = _controller;
  }

  void _updateController() {
    _controller?.dispose();
    _controller = TabController(
      length: widget.pageState._routes.length,
      initialIndex: widget.pageState.index,
      vsync: this,
    )..addListener(() {
        widget.pageState.index = _controller!.index;
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
