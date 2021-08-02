part of '../../routemaster.dart';

class AsyncPageBuilder extends StatefulPage<void> {
  final Stream<RouteSettings> Function(AsyncPageStatus status) pageBuilder;

  const AsyncPageBuilder({
    required this.pageBuilder,
  });

  @override
  PageState createState() {
    return AsyncPageState();
  }
}

/// The current state of an [IndexedPage]. Created when an instance of the page
/// is shown. Provides a list of track of the currently active index.
///
///   * [stacks] - a list of [PageStack] objects that manage the child routes.
///
///   * [index] - the currently active index.
///
class AsyncPageState extends PageState<AsyncPageBuilder> with ChangeNotifier {
  /// Initializes the state for an [IndexedPage].
  AsyncPageState();

  final _status = AsyncPageStatus();
  late PageWrapper _currentPage;
  late StreamSubscription<RouteSettings> _subscription;

  @override
  void initState() {
    super.initState();

    _routemaster!._delegate.addListener(() {
      if (_routemaster!.currentRoute != routeData) {
        // A navigation has occurred, stop listening to async events
        _subscription.cancel();
        _status._isCancelled = true;
      }
    });

    _currentPage = PageWrapper.fromPage(
      page: _NothingPage(),
      routeData: routeData,
    );

    _subscription = page.pageBuilder(_status).listen(_onPage);
  }

  void _onPage(RouteSettings newRoute) {
    print('Async page updated');

    final newPage = newRoute as Page;

    final result = _routemaster!._delegate._createPageWrapper(
      uri: routeData._uri,
      page: newPage,
      routeData: routeData,
      isLastRoute: true,
    );

    if (result is _NotFoundResult) {
      _currentPage = _routemaster!._delegate
          ._onUnknownRoute(
            _RouteRequest(
              requestSource: routeData.requestSource,
              uri: routeData._uri,
              isReplacement: routeData.isReplacement,
            ),
          )
          .first;
    } else if (result is _RedirectResult) {
      print('Redirecting to ${result.redirectPath}');
      _routemaster!.replace(result.redirectPath);
    } else if (result is _PageWrapperResult) {
      _currentPage = result.pageWrapper;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Page _getOrCreatePage() {
    return _currentPage._getOrCreatePage();
  }

  @override
  Page createPage() {
    return _currentPage.createPage();
  }

  @override
  Future<bool> maybePop<E extends Object?>([E? result]) {
    return _currentPage.maybePop(result);
  }

  @override
  Iterable<PageWrapper> getCurrentPages() {
    return _currentPage.getCurrentPages();
  }

  @override
  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    return _currentPage.maybeSetChildPages(pages);
  }
}

/// An invisible page pushed by default for an AsyncPage.
class _NothingPage extends Page<void> {
  @override
  Route<void> createRoute(BuildContext context) {
    return _NothingPageRoute(page: this);
  }
}

class _NothingPageRoute extends PageRoute<void> {
  _NothingPageRoute({
    required _NothingPage page,
  }) : super(settings: page);

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return const SizedBox();
  }

  @override
  bool get maintainState => false;

  @override
  Duration get transitionDuration => const Duration(microseconds: 1);
}

class AsyncPageStatus {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;
}
