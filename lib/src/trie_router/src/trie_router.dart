import 'package:routemaster/routemaster.dart';
import '../../path_parser.dart';
import 'errors.dart';
import 'router_result.dart';
import 'trie_node.dart';

/// The mode this router is using: relative or absolute
enum RouterMode {
  /// Router handles absolute paths
  absolute,

  /// Router handles relative paths
  relative,
}

/// A router for storing and retrieving routes that uses a Trie data structure.
class TrieRouter {
  /// The mode this router is using: relative or absolute
  final RouterMode mode;

  final Trie<String, PageBuilder> _trie;

  /// Initializes an empty router.
  TrieRouter({this.mode = RouterMode.absolute}) : _trie = Trie();

  /// Adds all the given [routes] to the router.
  /// The key of the map is the route.
  void addAll(final Map<String, PageBuilder> routes) {
    routes.forEach((key, value) {
      add(key, value);
    });
  }

  /// Throws a [ConflictingPathError] if there is a conflict.
  ///
  /// It is an error to add two segments prefixed with ':' at the same index.
  void add(final String rawPath, final PageBuilder value) {
    assert(rawPath.isNotEmpty);

    final path = _ensureInitialSlash(rawPath);

    final pathSegments = pathContext.split(path);
    assert(pathSegments.isNotEmpty);

    final list = List<String>.from(pathSegments);
    var current = _trie.root;

    // Work downwards through the trie, adding nodes as needed, and keeping
    // track of whether we add any nodes.
    var i = 0;
    for (final pathSegment in list) {
      // Throw an error when two segments start with ':' at the same index.
      if (pathSegment.startsWith(':') &&
          current.containsWhere((k) => k!.startsWith(':')) &&
          !current.containsWhere((k) => k == pathSegment)) {
        throw ConflictingPathError(
            list,
            List<String?>.from(list).sublist(0, i)
              ..add(current.getWhere((k) => k!.startsWith(':'))!.key));
      }

      final isLastSegment = i == list.length - 1;

      if (current.contains(pathSegment)) {
        if (isLastSegment) {
          if (current.get(pathSegment)!.value != null) {
            throw DuplicatePathError(PathParser.joinAllRelative(pathSegments));
          }

          // A child node has already been created, need to update it so it
          // points at the right value
          current.get(pathSegment)!.value = value;
        }
      } else {
        final template = pathContext.joinAll(pathSegments.take(i + 1));

        // No matching node for path, we need to create one
        if (isLastSegment) {
          // Last segment, add a node pointing at the value
          current.add(pathSegment, value, template);
        } else {
          // Not the last segment, add null node
          current.add(pathSegment, null, template);
        }
      }

      current = current.get(pathSegment)!;
      i++;
    }

    // Explicitly mark the end of a list of path segments. Otherwise, we might
    // say a path segment is present if it is a prefix of a different, longer
    // word that was added earlier.
    if (!current.contains(null)) {
      current.add(null, null, null);
    }
  }

  /// Returns all matching results from the router, or null if no match was
  /// found.
  List<RouterResult>? getAll(
    final String route, {
    final RouterResult? parent,
  }) {
    final results = _getAll(route, parent: parent);

    final list = <RouterResult>[];
    for (final result in results) {
      if (result == null) {
        // Route wasn't found
        return null;
      }

      list.add(result);
    }

    if (list.isEmpty) {
      return null;
    }

    return list;
  }

  Iterable<RouterResult?> _getAll(
    final String rawRoute, {
    final RouterResult? parent,
    final int debugCallCount = 0, // TODO: Remove
  }) sync* {
    final route = _ensureInitialSlash(rawRoute);

    if (debugCallCount > 100) {
      throw Exception(
        'Routemaster getAll: infinite loop detected: rawRoute=$rawRoute, route=$route, parent.pathSegment=${parent?.pathSegment}',
      );
    }

    final pathSegments = pathContext.split(PathParser.stripQueryString(route));
    final parameters = <String, String>{};
    RouterResult? lastResult;

    RouterResult buildResult(
      final int? count,
      final TrieNode<String?, PageBuilder?> node, {
      final String? unmatchedPath,
      final String? basePath,
    }) {
      final path = PathParser.joinAllRelative(
        count == null ? pathSegments : pathSegments.take(count + 1),
      );

      lastResult = parent == null
          ? RouterResult(
              builder: node.value!,
              pathParameters: Map.unmodifiable(parameters),
              pathSegment: path,
              pathTemplate: node.template!.replaceAll('*', ''),
              unmatchedPath: unmatchedPath,
              basePath: basePath,
            )
          : RouterResult(
              builder: node.value!,
              pathParameters: Map.unmodifiable(
                <String, String>{
                  ...parent.pathParameters,
                  ...parameters,
                },
              ),
              pathSegment: PathParser.joinRelative(
                parent.basePath ?? parent.pathSegment,
                path,
              ),
              pathTemplate: PathParser.joinRelative(
                parent.pathTemplate,
                node.template!.replaceAll('*', ''),
              ),
              unmatchedPath: unmatchedPath,
              basePath: basePath,
            );

      return lastResult!;
    }

    var current = _trie.root;
    TrieNode<String?, PageBuilder?>? lastWildcard;
    int? lastWildcardIndex;

    for (var i = 0; i < pathSegments.length; i++) {
      print('_getAll: $i');
      final segment = pathSegments[i];

      final wildcardNode = current.get('*');
      if (wildcardNode != null) {
        lastWildcard = wildcardNode;
        lastWildcardIndex = i;
      }

      if (current.contains(segment)) {
        current = current.get(segment)!;
        if (current.value != null) {
          yield buildResult(i, current);
        }

        continue;
      }

      final pathParamNode = current.getWhere((k) => k?.startsWith(':') == true);
      if (pathParamNode != null) {
        // If there is a segment that starts with `:`, we should match any
        // route.
        current = pathParamNode;

        // Add the current segment to the parameters. E.g. ':id': '123'
        parameters[current.key!.substring(1)] = segment;

        final nextSegment =
            i < pathSegments.length - 1 ? pathSegments[i + 1] : null;
        final nextSegmentIsParam = nextSegment?.startsWith(':') ?? false;
        if (!nextSegmentIsParam && current.value != null) {
          yield buildResult(i, current);
        }

        continue;
      }

      if (wildcardNode != null) {
        yield buildResult(
          null,
          wildcardNode,
          unmatchedPath: PathParser.joinAllRelative(
            pathSegments.skip(lastWildcardIndex!),
          ),
          basePath: PathParser.joinAllRelative(
            pathSegments.take(lastWildcardIndex),
          ),
        );
        return;
      }

      if (mode == RouterMode.relative) {
        // Nothing found yet, see if there's a recursive route
        final remaining = pathSegments.skip(i);
        if (remaining.isEmpty) {
          return;
        }

        final nextRoute = PathParser.joinAllRelative(remaining);
        if (nextRoute != rawRoute) {
          yield* _getAll(
            nextRoute,
            parent: lastResult ?? parent,
            debugCallCount: debugCallCount + 1,
          );
        }

        return;
      }

      // Nothing found
      if (lastWildcard != null) {
        yield buildResult(
          null,
          lastWildcard,
          unmatchedPath: PathParser.joinAllRelative(
            pathSegments.skip(lastWildcardIndex!),
          ),
          basePath: PathParser.joinAllRelative(
            pathSegments.take(lastWildcardIndex),
          ),
        );
        return;
      }

      yield null;
      return;
    }
  }

  static String _ensureInitialSlash(final String input) {
    if (input == '/') {
      return '/';
    }

    if (input[0] != '/') {
      return '/$input';
    }

    return input;
  }
}
