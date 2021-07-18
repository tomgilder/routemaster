part of '../../routemaster.dart';

/// Creates a page that can provide a stack of inner pages.
///
/// Usage:
///
/// ```
///   '/stack': (_) => StackPage(
///         child: StackContainerPage(),
///         defaultPath: 'one',
///       ),
///
///   '/stack/one': (_) => MaterialPage(child: StackPageOne()),
///   '/stack/one/two': (_) => MaterialPage(child: StackPageTwo()),
/// ```
///
/// Then within `StackContainerPage` you can show the stack like this:
///
/// ```
///   PageStackNavigator(stack: StackPage.of(context).stack)
/// ```
class StackPage extends StatefulPage<void> with PageContainer {
  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// The initial path for the stack.
  ///
  /// Can be absolute (`'/stack/one'`) or relative (`'one'`).
  ///
  /// This is used when trying to navigate to the stack's path directly.
  final String defaultPath;

  @override
  String get redirectPath => defaultPath;

  /// Optional function to customize the [Page] created for this route.
  /// If this is null, a [MaterialPage] is used.
  final Page Function(Widget child) pageBuilder;

  /// Initializes the page with a list of child [paths].
  const StackPage({
    required this.child,
    required this.defaultPath,
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

/// Injected into the widget tree to provide `StackPage.of(context)`
class _StackPageStateProvider extends InheritedNotifier {
  final StackPageState pageState;

  _StackPageStateProvider({
    required Widget child,
    required this.pageState,
  }) : super(
          child: child,
          notifier: pageState.stack,
        );
}

/// The current state of an [StackPage]. Created when an instance of the page
/// is shown.
class StackPageState extends PageState<StackPage> with ChangeNotifier {
  /// Initializes the state for an [StackPage].
  StackPageState();

  /// The stack for this page, which can be passed to a [StackNavigator].
  final stack = PageStack();

  @override
  Page createPage() {
    return page.pageBuilder(
      _StackPageStateProvider(
        pageState: this,
        child: page.child,
      ),
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
