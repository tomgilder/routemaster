part of '../../routemaster.dart';

class StackPage extends StatefulPage<void> with PageContainer {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  final String initialPath;

  @override
  String get redirectPath => initialPath;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  /// Initializes the page with a list of child [paths]. The provided [child]
  /// will normally show some kind of indexed navigation, such as tabs.
  const StackPage({
    required this.child,
    required this.initialPath,
    this.pageBuilder = _defaultPageBuilder,
  });

  @override
  PageState createState() {
    return StackPageState();
  }

  /// Retrieves the [StackPageState] from the closest [StackPage] ancestor.
  static StackPageState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<_StackPageStateProvider>();

    assert(
      provider != null,
      "Couldn't find an StackPageState from the given context.",
    );

    return provider!.pageState;
  }
}

/// Injected into the widget tree to provide `IndexedPage.of(context)`
class _StackPageStateProvider extends InheritedWidget {
  final StackPageState pageState;

  const _StackPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
        );

  @override
  bool updateShouldNotify(covariant _StackPageStateProvider oldWidget) {
    return oldWidget.pageState != pageState;
  }
}

/// The current state of an [StackPage]. Created when the an instance of the
/// page is shown.
class StackPageState extends PageState<StackPage> with ChangeNotifier {
  /// Initializes the state for an [StackPage].
  StackPageState();

  final stack = PageStack();

  @override
  Page createPage() {
    return page.pageBuilder(
      _StackPageStateProvider(pageState: this, child: page.child),
    );
  }

  @override
  bool maybeSetChildPages(Iterable<PageWrapper> pages) {
    return stack.maybeSetChildPages(pages);
  }

  @override
  Future<bool> maybePop<E extends Object?>([E? result]) {
    return stack.maybePop(result);
  }

  @override
  Iterable<PageWrapper> getCurrentPages() sync* {
    yield this;
    yield* stack._getCurrentPages();
  }
}
