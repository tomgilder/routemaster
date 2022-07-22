part of '../../routemaster.dart';

/// A page used to manage a [CupertinoTabBar] and its child routes.
///
/// Example:
///
/// ```
/// final tabState = NavigationBarPage.of(context);
/// final scaffold = CupertinoTabScaffold(
///   controller: tabState.controller,
///   tabBuilder: tabState.tabBuilder,
///   tabBar: CupertinoTabBar(
///     items: [
///       BottomNavigationBarItem(
///         label: 'Feed',
///         icon: Icon(CupertinoIcons.list_bullet),
///       ),
///       BottomNavigationBarItem(
///         label: 'Settings',
///         icon: Icon(CupertinoIcons.search),
///       ),
///     ],
///   ),
/// );
/// ```
class NavigationBarPage extends StatefulPage<void> with IndexedRouteMixIn {
  /// The child [Widget] that will display the [CupertinoTabBar].
  final Widget child;

  @override
  final List<String> paths;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  /// Specifies how tabs behave when used with the system back button.
  final TabBackBehavior backBehavior;

  /// Initializes the page with a list of child [paths].
  const NavigationBarPage({
    required this.child,
    required this.paths,
    this.pageBuilder = _defaultPageBuilder,
    this.backBehavior = TabBackBehavior.none,
  });

  @override
  PageState createState() {
    return NavigationBarPageState();
  }

  /// Retrieves the nearest [NavigationBarPageState] ancestor.
  static NavigationBarPageState of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_NavigationBarPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find a NavigationBarPageState from the given context.",
    );

    return provider!.pageState;
  }
}

class _NavigationBarPageStateProvider extends InheritedNotifier {
  final NavigationBarPageState pageState;

  const _NavigationBarPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState,
        );
}

/// The state for a [NavigationBarPage]. Creates and manages a
/// [CupertinoTabController] that can be accessed by calling
/// `NavigationBarPage.of(context).controller`.
class NavigationBarPageState extends PageState<NavigationBarPage>
    with ChangeNotifier, IndexedPageStateMixIn {
  /// Initializes the state for a [NavigationBarPage].
  NavigationBarPageState();

  /// A tab controller that is managed by this page state.
  ///
  /// Normally accessed by calling `NavigationBarPage.of(context).controller`.
  final CupertinoTabController controller = CupertinoTabController();

  @override
  TabBackBehavior get backBehavior => page.backBehavior;

  @override
  void initState() {
    super.initState();

    _routes = List.filled(page.paths.length, null);

    addListener(() {
      controller.index = index;
    });

    controller.addListener(() {
      index = controller.index;
    });
  }

  @override
  Page createPage() {
    return page.pageBuilder(
      _NavigationBarPageStateProvider(
        pageState: this,
        child: page.child,
      ),
    );
  }

  /// Returns the [PageStackNavigator] for the given [index].
  ///
  /// This can be passed to the [tabBuilder] property of a
  /// [CupertinoTabScaffold]:
  ///
  /// ```
  /// final tabState = NavigationBarPage.of(context);
  /// final scaffold = CupertinoTabScaffold(
  ///   controller: tabState.controller,
  ///   tabBuilder: tabState.tabBuilder,
  ///   ...
  /// )
  /// ```
  Widget tabBuilder(BuildContext context, int index) {
    return PageStackNavigator(stack: stacks[index]);
  }
}
